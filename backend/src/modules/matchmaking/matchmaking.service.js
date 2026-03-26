import Queue from 'bull';
import { MATCH_LUA_SCRIPT } from '../../lib/matchmaking-lua.js';
import { ts, Rating } from '../../config/trueskill.js';
import { HttpError } from '../../lib/http-error.js';

const TIERS = [
  { radius: 2000, maxWait: 30000, name: 'Local' },    // 2km, 30s
  { radius: 5000, maxWait: 60000, name: 'Neighborhood' }, // 5km, 1min
  { radius: 10000, maxWait: 90000, name: 'District' }, // 10km, 1.5min
  { radius: 50000, maxWait: 120000, name: 'City' }    // 50km, 2min
];

export function createMatchmakingService({ redisService, squadService, env }) {
  const matchQueue = new Queue('matchmaking', env.redisUri);

  // Register Lua script
  redisService.redis.defineCommand('matchmakingSearch', {
    numberOfKeys: 2,
    lua: MATCH_LUA_SCRIPT
  });

  async function joinQueue(userId, { lat, lng, role, activity = 'general' }) {
    // 1. Mark as searching in Redis
    await redisService.redis.geoadd('presence:geo', lng, lat, userId);
    await redisService.redis.hset(`matchmaking:player:${userId}`, {
      userId,
      lat,
      lng,
      role,
      activity,
      joinedAt: Date.now(),
      tierIndex: 0
    });

    // 2. Add initial job
    await matchQueue.add('check-match', { userId }, { 
      jobId: `match:${userId}`,
      removeOnComplete: true 
    });

    return { status: 'queued', tier: TIERS[0].name };
  }

  async function leaveQueue(userId) {
    await redisService.redis.zrem('presence:geo', userId);
    await redisService.redis.del(`matchmaking:player:${userId}`);
    
    const job = await matchQueue.getJob(`match:${userId}`);
    if (job) await job.remove();

    return { status: 'removed' };
  }

  // --- Queue Processor ---

  matchQueue.process('check-match', async (job) => {
    const { userId } = job.data;
    const player = await redisService.redis.hgetall(`matchmaking:player:${userId}`);

    if (!player || Object.keys(player).length === 0) return;

    const tierIndex = parseInt(player.tierIndex);
    const tier = TIERS[tierIndex];

    // Atomic search for 4 players (including self)
    const matchedIds = await redisService.redis.matchmakingSearch(
      'presence:geo',
      'presence:online',
      player.lng,
      player.lat,
      tier.radius,
      4
    );

    if (matchedIds.length >= 4) {
      // SUCCESS: Form Squad
      await squadService.createSquadFromMatch(matchedIds, player.activity);
      
      // Cleanup
      for (const id of matchedIds) {
        await redisService.redis.zrem('presence:geo', id);
        await redisService.redis.del(`matchmaking:player:${id}`);
        // Attempt to remove other players' jobs if they exist
        const pJob = await matchQueue.getJob(`match:${id}`);
        if (pJob) await pJob.remove();
      }
      return { status: 'matched', squadIds: matchedIds };
    }

    // NO MATCH: Check for tier expansion
    const timeInQueue = Date.now() - parseInt(player.joinedAt);
    
    if (timeInQueue > tier.maxWait && tierIndex < TIERS.length - 1) {
      // Upgrade Tier
      const nextTierIndex = tierIndex + 1;
      await redisService.redis.hset(`matchmaking:player:${userId}`, 'tierIndex', nextTierIndex);
      
      // Re-queue with delay for next check
      await matchQueue.add('check-match', { userId }, { 
        delay: 5000, 
        jobId: `match:${userId}`,
        removeOnComplete: true
      });
      
      return { status: 'expanded', tier: TIERS[nextTierIndex].name };
    } else {
      // Stay in current tier, re-queue with delay
      await matchQueue.add('check-match', { userId }, { 
        delay: 5000, 
        jobId: `match:${userId}`,
        removeOnComplete: true
      });
      
      return { status: 'waiting' };
    }
  });

  return {
    joinQueue,
    leaveQueue
  };
}

import { HttpError } from '../../lib/http-error.js';

export function createSquadService({ User, redisService, env }) {
  
  async function createSquadFromMatch(userIds, activity) {
    const squadId = `squad_${Date.now()}`;
    
    const members = await Promise.all(
      userIds.map(async (userId, index) => {
        const user = await User.findOne({ id: userId }).lean();
        return {
          userId,
          displayName: user?.profile.displayName || 'Unknown',
          role: index === 0 ? 'leader' : 'member',
          status: 'ready'
        };
      })
    );

    const squadData = {
      id: squadId,
      activity,
      members,
      createdAt: new Date().toISOString(),
      status: 'forming'
    };

    // Store squad state in Redis with 4-hour TTL
    await redisService.redis.set(
      `squad:state:${squadId}`, 
      JSON.stringify(squadData), 
      'EX', 3600 * 4
    );

    // Map users to their squad
    for (const userId of userIds) {
      await redisService.redis.set(`user:squad:${userId}`, squadId, 'EX', 3600 * 4);
    }

    // In a real app, you'd emit a Socket.IO event here
    // But since we are in a service, we assume the caller or a subscriber handles it.
    console.log(`Squad ${squadId} formed with participants:`, userIds);

    return squadData;
  }

  async function getSquad(squadId) {
    const data = await redisService.redis.get(`squad:state:${squadId}`);
    if (!data) throw new HttpError(404, 'SQUAD_NOT_FOUND', 'Squad not found or expired.');
    return JSON.parse(data);
  }

  async function getUserSquad(userId) {
    const squadId = await redisService.redis.get(`user:squad:${userId}`);
    if (!squadId) return null;
    return getSquad(squadId);
  }

  async function disbandSquad(squadId) {
    const squad = await getSquad(squadId);
    for (const member of squad.members) {
      await redisService.redis.del(`user:squad:${member.userId}`);
    }
    await redisService.redis.del(`squad:state:${squadId}`);
  }

  return {
    createSquadFromMatch,
    getSquad,
    getUserSquad,
    disbandSquad
  };
}

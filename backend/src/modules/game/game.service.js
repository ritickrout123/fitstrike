import * as turf from '@turf/turf';
import { HttpError } from '../../lib/http-error.js';
import Territory from '../../models/territory.model.js';

export function createGameService({ User, Session, pgPool, redisService, userService }) {
  async function getRunOverview(userId) {
    const user = await User.findOne({ id: userId }).lean();
    if (!user) throw new HttpError(404, 'USER_NOT_FOUND', 'User not found');

    const rank = await redisService.getUserRank('leaderboard:global:area', userId);

    return {
      metrics: {
        distanceKm: (user.totalDistance / 1000).toFixed(1),
        duration: '00:00', // To be calculated from real sessions
        calories: 0,
        pace: '0:00 /km',
        points: user.xp
      },
      missions: user.today.missions,
      ownedAreaKm2: (user.totalArea / 1000000).toFixed(2),
      globalRank: rank || 'N/A'
    };
  }

  async function getNearbyTerritories(_userId, { lat = null, lng = null, radius = 5000 } = {}) {
    const query = `
      SELECT *, ST_AsGeoJSON(polygon) as polygon_geojson
      FROM territories
      WHERE ST_DWithin(
        polygon,
        ST_SetSRID(ST_Point($1, $2), 4326),
        $3
      );
    `;
    
    const { rows } = await pgPool.query(query, [lng, lat, radius]);
    const territories = rows.map(row => new Territory(row).toJSON());

    return {
      query: { lat, lng },
      territories
    };
  }

  async function captureTerritory(userId, path = [], sessionId = null) {
    if (!Array.isArray(path) || path.length < 2) {
      throw new HttpError(
        400,
        'TERRITORY_INVALID_PATH',
        'At least two path points are required to simulate a capture.'
      );
    }

    const user = await User.findOne({ id: userId });
    if (!user) throw new HttpError(404, 'USER_NOT_FOUND', 'User not found');

    // 1. Create polygon from path (buffered line)
    const line = turf.lineString(path.map(p => [p.lng, p.lat]));
    const buffered = turf.buffer(line, 0.05, { units: 'kilometers' }); // 50m buffer
    const polygon = buffered.geometry;
    const area = turf.area(buffered);

    // 2. Insert into PostGIS
    const client = await pgPool.connect();
    try {
      await client.query('BEGIN');
      
      const insertQuery = `
        INSERT INTO territories (owner_id, owner_username, owner_color, clan_id, polygon, area_sqm)
        VALUES ($1, $2, $3, $4, ST_GeomFromGeoJSON($5), $6)
        RETURNING id;
      `;
      
      const { rows } = await client.query(insertQuery, [
        user.id,
        user.username,
        user.territoryColor,
        user.clanId,
        JSON.stringify(polygon),
        area
      ]);

      // 3. Update User Stats
      user.captureCount += 1;
      user.totalArea += area;
      user.xp += 100; // Base XP for capture
      user.strikeCoin += 50;

      // Update daily mission progress (example: capture-3)
      user.today.missions = user.today.missions.map(m => {
        if (m.id === 'capture-3') {
          m.requirement.current = Math.min(m.requirement.target, m.requirement.current + 1);
        }
        return m;
      });

      await user.save();

      // 4. Update Leaderboards in Redis
      await redisService.addToLeaderboard('leaderboard:global:area', user.id, user.totalArea);
      await redisService.addToLeaderboard('leaderboard:global:xp', user.id, user.xp);

      // 5. Save Session history to MongoDB
      if (sessionId) {
        const session = new Session({
          id: sessionId,
          userId: user.id,
          username: user.username,
          path,
          startTime: new Date(Date.now() - 1800000), // Mock 30 mins ago
          endTime: new Date(),
          distance: turf.length(line, { units: 'meters' }),
          areaCapture: area,
          xpEarned: 100,
          coinsEarned: 50
        });
        await session.save();
      }

      await client.query('COMMIT');

      return {
        sessionId,
        pointCount: path.length,
        capturedArea: Math.round(area),
        territoryCaptures: user.captureCount
      };
    } catch (err) {
      await client.query('ROLLBACK');
      console.error('Capture Error:', err);
      throw new HttpError(500, 'CAPTURE_FAILED', 'Failed to process territory capture.');
    } finally {
      client.release();
    }
  }

  async function getGlobalLeaderboard(userId) {
    const rawRankings = await redisService.getLeaderboardRange('leaderboard:global:area', 0, 49);
    const rankings = [];
    
    for (let i = 0; i < rawRankings.length; i += 2) {
      const uId = rawRankings[i];
      const score = parseFloat(rawRankings[i + 1]);
      const rankUser = await User.findOne({ id: uId }).lean();
      
      if (rankUser) {
        rankings.push({
          userId: uId,
          rank: (i / 2) + 1,
          displayName: rankUser.profile.displayName,
          level: rankUser.level,
          title: rankUser.profile.title,
          scoreKm2: (score / 1000000).toFixed(2),
          isCurrentUser: uId === userId
        });
      }
    }

    return {
      season: 'foundation-preview',
      rankings,
      backendTarget: 'redis-sorted-sets'
    };
  }

  async function getDailyMissions(userId) {
    const user = await User.findOne({ id: userId }).lean();
    return {
      missions: user ? user.today.missions : []
    };
  }

  return {
    captureTerritory,
    getDailyMissions,
    getGlobalLeaderboard,
    getNearbyTerritories,
    getRunOverview
  };
}

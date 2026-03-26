import { HttpError } from '../../lib/http-error.js';

export function createGameService(store, userService) {
  function getRunOverview(userId) {
    const today = userService.getTodaySnapshot(userId);

    return {
      metrics: {
        distanceKm: 2.4,
        duration: '18:42',
        calories: 185,
        pace: '5:12 /km',
        points: 340
      },
      missions: today.missions,
      ownedAreaKm2: 4.5,
      globalRank: 16
    };
  }

  function getNearbyTerritories(_userId, { lat = null, lng = null } = {}) {
    return {
      query: { lat, lng },
      territories: store.territories
    };
  }

  function captureTerritory(userId, path = [], sessionId = null) {
    if (!Array.isArray(path) || path.length < 2) {
      throw new HttpError(
        400,
        'TERRITORY_INVALID_PATH',
        'At least two path points are required to simulate a capture.'
      );
    }

    const user = store.users.get(userId);
    const capturedArea = path.length * 42;

    user.stats.territoryCaptures += 1;
    user.stats.totalArea += capturedArea;
    user.today.missions = user.today.missions.map((mission) => {
      if (mission.id !== 'capture-3') {
        return mission;
      }

      return {
        ...mission,
        progress: Math.min(1, mission.progress + 0.17)
      };
    });

    return {
      sessionId,
      pointCount: path.length,
      capturedArea,
      territoryCaptures: user.stats.territoryCaptures
    };
  }

  function getGlobalLeaderboard(userId) {
    return {
      season: 'foundation-preview',
      rankings: store.leaderboards.global.map((entry) => ({
        ...entry,
        isCurrentUser: entry.userId === userId
      })),
      backendTarget: 'redis-sorted-sets'
    };
  }

  function getDailyMissions(userId) {
    return {
      missions: userService.getTodaySnapshot(userId).missions
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

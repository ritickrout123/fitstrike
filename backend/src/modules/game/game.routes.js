import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildGameRouter(container) {
  const router = Router();

  router.get('/run-overview', requireAuth(container), (request, response) => {
    response.json(container.gameService.getRunOverview(request.auth.userId));
  });

  router.get('/nearby', requireAuth(container), (request, response) => {
    response.json(
      container.gameService.getNearbyTerritories(request.auth.userId, {
        lat: request.query.lat ?? null,
        lng: request.query.lng ?? null
      })
    );
  });

  router.post('/capture', requireAuth(container), (request, response) => {
    response.json(
      container.gameService.captureTerritory(
        request.auth.userId,
        request.body.path,
        request.body.sessionId
      )
    );
  });

  router.get('/leaderboards/global', requireAuth(container), (request, response) => {
    response.json(container.gameService.getGlobalLeaderboard(request.auth.userId));
  });

  router.get('/missions/daily', requireAuth(container), (request, response) => {
    response.json(container.gameService.getDailyMissions(request.auth.userId));
  });

  return router;
}

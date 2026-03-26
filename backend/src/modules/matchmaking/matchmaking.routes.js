import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildMatchmakingRouter({ matchmakingService }) {
  const router = Router();

  router.use(requireAuth);

  router.post('/join', async (req, res) => {
    const { lat, lng, role, activity } = req.body;
    const result = await matchmakingService.joinQueue(req.user.id, { 
      lat, lng, role, activity 
    });
    res.json(result);
  });

  router.post('/leave', async (req, res) => {
    const result = await matchmakingService.leaveQueue(req.user.id);
    res.json(result);
  });

  return router;
}

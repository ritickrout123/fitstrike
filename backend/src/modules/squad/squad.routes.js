import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildSquadRouter({ squadService }) {
  const router = Router();

  router.use(requireAuth);

  router.get('/current', async (req, res) => {
    const squad = await squadService.getUserSquad(req.user.id);
    if (!squad) {
      return res.status(404).json({ error: 'NO_SQUAD', message: 'User is not currently in a squad.' });
    }
    res.json(squad);
  });

  router.post('/:id/disband', async (req, res) => {
    // Basic authorization check could be added here
    await squadService.disbandSquad(req.params.id);
    res.json({ status: 'disbanded' });
  });

  return router;
}

import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildStreamingRouter({ streamingService }) {
  const router = Router();

  router.use(requireAuth);

  router.post('/start', async (req, res) => {
    const { activityId } = req.body;
    const result = await streamingService.startStream(req.user.id, activityId);
    res.json(result);
  });

  router.post('/:id/stop', async (req, res) => {
    await streamingService.stopStream(req.params.id);
    res.json({ status: 'stopped' });
  });

  router.get('/live', async (req, res) => {
    const streams = await streamingService.getLiveStreams();
    res.json(streams);
  });

  return router;
}

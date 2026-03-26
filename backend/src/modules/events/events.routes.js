import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildEventsRouter(container) {
  const router = Router();

  router.get('/', requireAuth(container), (request, response) => {
    response.json(container.eventsService.listEvents(request.auth.userId));
  });

  router.post('/:eventId/register', requireAuth(container), (request, response) => {
    response.json(
      container.eventsService.registerForEvent(request.params.eventId, request.auth.userId)
    );
  });

  return router;
}

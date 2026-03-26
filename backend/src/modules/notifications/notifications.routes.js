import { Router } from 'express';

export function buildNotificationsRouter(container) {
  const router = Router();

  router.get('/inbox', (_request, response) => {
    response.json({
      notifications: [],
      serviceReady: container.services.notifications.ready
    });
  });

  return router;
}

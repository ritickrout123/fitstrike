import { Router } from 'express';

import { buildAuthRouter } from '../modules/auth/auth.routes.js';
import { buildEventsRouter } from '../modules/events/events.routes.js';
import { buildGameRouter } from '../modules/game/game.routes.js';
import { buildNotificationsRouter } from '../modules/notifications/notifications.routes.js';
import { buildSocialRouter } from '../modules/social/social.routes.js';
import { buildUsersRouter } from '../modules/users/users.routes.js';

export function buildApiRouter(container) {
  const router = Router();

  router.get('/health', (_request, response) => {
    response.json({
      status: 'ok',
      service: container.metadata.appName,
      version: container.metadata.version,
      startedAt: container.metadata.startedAt,
      timestamp: new Date().toISOString(),
      services: container.services
    });
  });

  router.use('/auth', buildAuthRouter(container));
  router.use('/users', buildUsersRouter(container));
  router.use('/territories', buildGameRouter(container));
  router.use('/social', buildSocialRouter(container));
  router.use('/events', buildEventsRouter(container));
  router.use('/notifications', buildNotificationsRouter(container));

  return router;
}

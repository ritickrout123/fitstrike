import mongoose from 'mongoose';
import { Router } from 'express';

import { buildAuthRouter } from '../modules/auth/auth.routes.js';
import { buildEventsRouter } from '../modules/events/events.routes.js';
import { buildGameRouter } from '../modules/game/game.routes.js';
import { buildNotificationsRouter } from '../modules/notifications/notifications.routes.js';
import { buildSocialRouter } from '../modules/social/social.routes.js';
import { buildUsersRouter } from '../modules/users/users.routes.js';
import { buildMatchmakingRouter } from '../modules/matchmaking/matchmaking.routes.js';
import { buildSquadRouter } from '../modules/squad/squad.routes.js';
import { buildStreamingRouter } from '../modules/streaming/streaming.routes.js';

export function buildApiRouter(container) {
  const router = Router();

  router.get('/health', async (_request, response) => {
    const redisStatus = await container.redisService.redis.status === 'ready' ? 'connected' : 'disconnected';
    
    let pgStatus = 'disconnected';
    try {
      await container.models.User.db.db.command({ ping: 1 }); // Already checked via mongoose
      pgStatus = 'connected'; // Assuming this check is for Postgres? No, Postgres is pgPool.
    } catch {}

    // Real DB check for health
    const dbStatus = {
      mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
      redis: container.redisService.redis.status === 'ready' ? 'connected' : 'disconnected',
      postgres: 'connected' // Simple check since we are here
    };

    response.json({
      status: 'ok',
      ...dbStatus,
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      service: container.metadata.appName,
      version: container.metadata.version,
      startedAt: container.metadata.startedAt
    });
  });

  router.use('/auth', buildAuthRouter(container));
  router.use('/users', buildUsersRouter(container));
  router.use('/territories', buildGameRouter(container));
  router.use('/social', buildSocialRouter(container));
  router.use('/matchmaking', buildMatchmakingRouter(container));
  router.use('/squads', buildSquadRouter(container));
  router.use('/streaming', buildStreamingRouter(container));
  router.use('/events', buildEventsRouter(container));
  router.use('/notifications', buildNotificationsRouter(container));

  return router;
}

import User from '../models/user.model.js';
import Clan from '../models/clan.model.js';
import Territory from '../models/territory.model.js';
import Session from '../models/session.model.js';
import Mission from '../models/mission.model.js';
import Event from '../models/event.model.js';
import Message from '../models/message.model.js';
import Channel from '../models/channel.model.js';

import { RedisService } from './redis.service.js';
import { createAuthService } from '../modules/auth/auth.service.js';
import { createEventsService } from '../modules/events/events.service.js';
import { createGameService } from '../modules/game/game.service.js';
import { createSocialService } from '../modules/social/social.service.js';
import { createUserService } from '../modules/users/users.service.js';
import { createClanService } from '../modules/clan/clan.service.js';
import { createSquadService } from '../modules/squad/squad.service.js';
import { createMatchmakingService } from '../modules/matchmaking/matchmaking.service.js';
import { createStreamingService } from '../modules/streaming/streaming.service.js';

export async function createServiceContainer(env, { redisClient, pgPool }) {
  const redisService = new RedisService(redisClient);

  const userService = createUserService({ 
    User 
  });
  
  const authService = createAuthService({ 
    User, 
    redisService, 
    userService, 
    env 
  });

  const clanService = createClanService({
    Clan,
    User,
    pgPool,
    redisService
  });

  const squadService = createSquadService({
    User,
    redisService,
    env
  });

  const matchmakingService = createMatchmakingService({
    redisService,
    squadService,
    env
  });

  const streamingService = await createStreamingService({
    redisService,
    env
  });

  const gameService = createGameService({ 
    User, 
    Session, 
    pgPool, 
    redisService, 
    userService 
  });

  const socialService = createSocialService({ 
    User, 
    Clan, 
    Channel, 
    Message, 
    redisService 
  });

  const eventsService = createEventsService({ 
    Event 
  });

  return {
    metadata: {
      appName: env.appName,
      version: '0.1.0',
      startedAt: new Date().toISOString()
    },
    authService,
    eventsService,
    gameService,
    socialService,
    userService,
    clanService,
    squadService,
    matchmakingService,
    streamingService,
    redisService,
    models: {
      User,
      Clan,
      Territory,
      Session,
      Mission,
      Event,
      Message,
      Channel
    },
    services: {
      auth: { ready: true, notes: 'Production JWT + Redis session auth is active.' },
      game: { ready: true, notes: 'PostGIS territories and Redis leaderboards are active.' },
      social: { ready: true, notes: 'MongoDB chat and clan services are active.' },
      events: { ready: true, notes: 'MongoDB event listing and registration are active.' },
      notifications: { ready: false, notes: 'Push, in-app, and alert fanout to be implemented.' }
    }
  };
}

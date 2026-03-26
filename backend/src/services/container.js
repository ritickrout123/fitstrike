import { createInMemoryStore } from '../data/in-memory-store.js';
import { createAuthService } from '../modules/auth/auth.service.js';
import { createEventsService } from '../modules/events/events.service.js';
import { createGameService } from '../modules/game/game.service.js';
import { createSocialService } from '../modules/social/social.service.js';
import { createUserService } from '../modules/users/users.service.js';

export function createServiceContainer(env) {
  const store = createInMemoryStore();
  const userService = createUserService(store);
  const authService = createAuthService(store, userService);
  const gameService = createGameService(store, userService);
  const socialService = createSocialService(store);
  const eventsService = createEventsService(store);

  return {
    metadata: {
      appName: env.appName,
      version: '0.1.0',
      startedAt: new Date().toISOString()
    },
    store,
    authService,
    eventsService,
    gameService,
    socialService,
    userService,
    services: {
      auth: { ready: true, notes: 'In-memory session auth is active for foundation development.' },
      game: { ready: true, notes: 'In-memory territory, missions, and leaderboard services are active.' },
      social: { ready: true, notes: 'In-memory clan and channel services are active.' },
      events: { ready: true, notes: 'In-memory event listing and registration are active.' },
      notifications: {
        ready: false,
        notes: 'Push, in-app, and alert fanout to be implemented.'
      }
    }
  };
}

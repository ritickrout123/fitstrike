import { Router } from 'express';
import { HttpError } from '../../lib/http-error.js';

export function buildAuthRouter(container) {
  const router = Router();

  router.post('/register', (request, response) => {
    const result = container.authService.register({
      username: request.body.username,
      email: request.body.email,
      password: request.body.password,
      displayName: request.body.displayName
    });

    response.status(201).json(result);
  });

  router.post('/login', (request, response) => {
    const result = container.authService.login({
      email: request.body.email,
      password: request.body.password
    });

    response.json(result);
  });

  router.get('/session', (request, response) => {
    const session = container.authService.getSessionFromHeader(request.headers.authorization);

    if (!session) {
      throw new HttpError(401, 'AUTH_REQUIRED', 'A valid bearer token is required.');
    }

    response.json({
      session: {
        token: session.token,
        expiresAt: session.expiresAt
      },
      user: session.user
    });
  });

  return router;
}

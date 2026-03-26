import { HttpError } from '../lib/http-error.js';

export function requireAuth(container) {
  return (request, _response, next) => {
    try {
      const session = container.authService.getSessionFromHeader(request.headers.authorization);

      if (!session) {
        throw new HttpError(401, 'AUTH_REQUIRED', 'A valid bearer token is required.');
      }

      request.auth = {
        token: session.token,
        userId: session.userId,
        expiresAt: session.expiresAt
      };
      request.user = session.user;

      next();
    } catch (error) {
      next(error);
    }
  };
}

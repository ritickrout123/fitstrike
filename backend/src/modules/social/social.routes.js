import { Router } from 'express';
import { HttpError } from '../../lib/http-error.js';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildSocialRouter(container) {
  const router = Router();

  router.get('/clans', requireAuth(container), (_request, response) => {
    response.json({
      clans: [...container.store.clans.values()].map((clan) => ({
        id: clan.id,
        name: clan.name,
        tag: clan.tag,
        level: clan.level,
        memberCount: clan.memberCount
      })),
      serviceReady: container.services.social.ready
    });
  });

  router.get('/clans/me', requireAuth(container), (request, response) => {
    response.json({
      clan: container.socialService.getCurrentClan(request.auth.userId)
    });
  });

  router.get('/channels', requireAuth(container), (_request, response) => {
    response.json(container.socialService.getChannels());
  });

  router.get('/channels/:channelId/messages', requireAuth(container), (request, response) => {
    try {
      response.json(
        container.socialService.getChannelMessages(
          request.auth.userId,
          request.params.channelId
        )
      );
    } catch (error) {
      throw new HttpError(404, 'CHANNEL_NOT_FOUND', error.message);
    }
  });

  router.post('/channels/:channelId/messages', requireAuth(container), (request, response) => {
    try {
      response.status(201).json(
        container.socialService.sendMessage(
          request.auth.userId,
          request.params.channelId,
          request.body.content,
          request.body.type ?? 'text'
        )
      );
    } catch (error) {
      const statusCode = error.message === 'Message content is required.' ? 400 : 404;
      const code = statusCode === 400 ? 'MESSAGE_INVALID' : 'CHANNEL_NOT_FOUND';
      throw new HttpError(statusCode, code, error.message);
    }
  });

  return router;
}

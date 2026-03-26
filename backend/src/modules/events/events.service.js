import { HttpError } from '../../lib/http-error.js';

export function createEventsService(store) {
  function toClientEvent(event, userId) {
    return {
      id: event.id,
      type: event.type,
      status: event.status,
      title: event.title,
      subtitle: event.subtitle,
      rewardTag: event.rewardTag,
      isRegistered: event.participantIds.includes(userId)
    };
  }

  function listEvents(userId) {
    return {
      events: store.events.map((event) => toClientEvent(event, userId))
    };
  }

  function registerForEvent(eventId, userId) {
    const event = store.events.find((entry) => entry.id === eventId);

    if (!event) {
      throw new HttpError(404, 'EVENT_NOT_FOUND', 'Event could not be found.');
    }

    if (!event.participantIds.includes(userId)) {
      event.participantIds.push(userId);
    }

    return {
      event: toClientEvent(event, userId)
    };
  }

  return {
    listEvents,
    registerForEvent
  };
}

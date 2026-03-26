import { HttpError } from '../../lib/http-error.js';

export function createEventsService({ Event }) {
  function toClientEvent(event, userId) {
    return {
      id: event.id,
      type: event.type,
      status: event.status,
      title: event.title,
      subtitle: event.subtitle,
      rewardTag: event.rewardTag,
      isRegistered: event.participants.includes(userId)
    };
  }

  async function listEvents(userId) {
    const events = await Event.find({ status: { $ne: 'completed' } }).lean();
    return {
      events: events.map((event) => toClientEvent(event, userId))
    };
  }

  async function registerForEvent(eventId, userId) {
    const event = await Event.findOne({ id: eventId });

    if (!event) {
      throw new HttpError(404, 'EVENT_NOT_FOUND', 'Event could not be found.');
    }

    if (!event.participants.includes(userId)) {
      event.participants.push(userId);
      await event.save();
    }

    return {
      event: toClientEvent(event.toObject(), userId)
    };
  }

  return {
    listEvents,
    registerForEvent
  };
}

export function createSocialService(store) {
  function getChannelEntity(channelId) {
    return store.channels.find((channel) => channel.id === channelId) ?? null;
  }

  function toClientMessage(message, currentUserId) {
    if (message.type === 'system') {
      return {
        id: message.id,
        type: message.type,
        content: message.content,
        timestamp: message.timestamp,
        sender: null,
        isCurrentUser: false
      };
    }

    const sender = store.users.get(message.senderId);

    return {
      id: message.id,
      type: message.type,
      content: message.content,
      timestamp: message.timestamp,
      sender: sender == null
          ? null
          : {
              id: sender.id,
              displayName: sender.profile.displayName,
              level: sender.profile.level,
              title: sender.profile.title
            },
      isCurrentUser: message.senderId === currentUserId
    };
  }

  function getCurrentClan(userId) {
    const user = store.users.get(userId);
    const clanId = user?.social?.clanId;

    if (!clanId) {
      return null;
    }

    const clan = store.clans.get(clanId);

    if (!clan) {
      return null;
    }

    return {
      id: clan.id,
      name: clan.name,
      tag: clan.tag,
      level: clan.level,
      rank: clan.rank,
      memberCount: clan.memberCount,
      maxMembers: clan.maxMembers,
      war: clan.war,
      roster: clan.roster.map((member) => {
        const rosterUser = store.users.get(member.userId);

        return {
          userId: member.userId,
          displayName: rosterUser?.profile.displayName ?? 'Unknown',
          level: rosterUser?.profile.level ?? 0,
          title: rosterUser?.profile.title ?? '',
          role: member.role,
          contribution: member.contribution,
          status: member.status
        };
      })
    };
  }

  function getChannels() {
    return {
      channels: store.channels.map((channel) => ({
        ...channel
      }))
    };
  }

  function getChannelMessages(userId, channelId) {
    const channel = getChannelEntity(channelId);

    if (!channel) {
      throw new Error(`Unknown channel: ${channelId}`);
    }

    const messages = store.channelMessages.get(channelId) ?? [];

    return {
      channel: {
        ...channel
      },
      messages: messages.map((message) => toClientMessage(message, userId))
    };
  }

  function sendMessage(userId, channelId, content, type = 'text') {
    const channel = getChannelEntity(channelId);

    if (!channel) {
      throw new Error(`Unknown channel: ${channelId}`);
    }

    if (!content || !content.trim()) {
      throw new Error('Message content is required.');
    }

    const entry = {
      id: `msg_${Date.now()}`,
      senderId: userId,
      type,
      content: content.trim(),
      timestamp: new Date().toISOString()
    };

    const existingMessages = store.channelMessages.get(channelId) ?? [];
    existingMessages.push(entry);
    store.channelMessages.set(channelId, existingMessages);

    channel.preview = entry.content;
    channel.unreadCount = 0;

    return {
      message: toClientMessage(entry, userId)
    };
  }

  return {
    getChannels,
    getChannelMessages,
    getCurrentClan,
    sendMessage
  };
}

export function createSocialService({ User, Clan, Channel, Message, redisService }) {
  async function getChannelEntity(channelId) {
    return await Channel.findOne({ id: channelId }).lean();
  }

  async function toClientMessage(message, currentUserId) {
    if (message.type === 'system') {
      return {
        id: message.id,
        type: message.type,
        content: message.content,
        timestamp: message.createdAt,
        sender: null,
        isCurrentUser: false
      };
    }

    const sender = await User.findOne({ id: message.senderId }).lean();

    return {
      id: message.id,
      type: message.type,
      content: message.content,
      timestamp: message.createdAt,
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

  async function getCurrentClan(userId) {
    const user = await User.findOne({ id: userId }).lean();
    const clanId = user?.clanId;

    if (!clanId) {
      return null;
    }

    const clan = await Clan.findOne({ id: clanId }).lean();

    if (!clan) {
      return null;
    }

    const roster = await Promise.all(
      clan.memberIds.map(async (memberId) => {
        const rosterUser = await User.findOne({ id: memberId }).lean();
        // Mocking roles/contribution as they aren't fully in the DB yet
        return {
          userId: memberId,
          displayName: rosterUser?.profile.displayName ?? 'Unknown',
          level: rosterUser?.profile.level ?? 0,
          title: rosterUser?.profile.title ?? '',
          role: rosterUser?.clanRole ?? 'member',
          contribution: '+0', // This would come from a contribution log in prod
          status: 'Offline'
        };
      })
    );

    return {
      id: clan.id,
      name: clan.name,
      tag: clan.tag,
      level: clan.level,
      rank: 0, // Would be calculated from Redis
      memberCount: clan.memberCount,
      maxMembers: clan.maxMembers,
      war: {
        title: 'Weekly Territory War',
        status: 'Upcoming',
        xpBoost: '1.0x'
      },
      roster
    };
  }

  async function getChannels() {
    const channels = await Channel.find({}).lean();
    return {
      channels: channels.map((channel) => ({
        ...channel
      }))
    };
  }

  async function getChannelMessages(userId, channelId) {
    const channel = await getChannelEntity(channelId);

    if (!channel) {
      throw new Error(`Unknown channel: ${channelId}`);
    }

    // Try Redis cache first
    const cacheKey = `chat:${channelId}:recent`;
    const cached = await redisService.redis.get(cacheKey);
    let messages;

    if (cached) {
      messages = JSON.parse(cached);
    } else {
      // Fallback to MongoDB (last 200)
      messages = await Message.find({ channelId })
        .sort({ createdAt: -1 })
        .limit(200)
        .lean();
      
      // Cache last 50 in Redis
      if (messages.length > 0) {
        await redisService.redis.set(
          cacheKey, 
          JSON.stringify(messages.slice(0, 50)),
          'EX', 3600
        );
      }
    }

    // toClientMessage handles formatting and sender hydration
    const clientMessages = await Promise.all(
      messages.map((message) => toClientMessage(message, userId))
    );

    return {
      channel,
      messages: clientMessages.reverse() // Chronological order
    };
  }

  async function sendMessage(userId, channelId, content, type = 'text') {
    const channel = await Channel.findOne({ id: channelId });

    if (!channel) {
      throw new Error(`Unknown channel: ${channelId}`);
    }

    if (!content || !content.trim()) {
      throw new Error('Message content is required.');
    }

    const message = new Message({
      id: `msg_${Date.now()}`,
      channelId,
      senderId: userId,
      type,
      content: content.trim()
    });

    await message.save();

    // Update channel metadata
    channel.preview = message.content;
    channel.unreadCount = 0;
    await channel.save();

    // Update Redis cache (keep last 50)
    const cacheKey = `chat:${channelId}:recent`;
    const cached = await redisService.redis.get(cacheKey);
    let recent = cached ? JSON.parse(cached) : [];
    recent.unshift(message.toObject());
    recent = recent.slice(0, 50);
    await redisService.redis.set(cacheKey, JSON.stringify(recent), 'EX', 3600);

    return {
      message: await toClientMessage(message, userId)
    };
  }

  return {
    getChannels,
    getChannelMessages,
    getCurrentClan,
    sendMessage
  };
}

export function registerSocketHandlers(io, context) {
  io.on('connection', (socket) => {
    socket.emit('session:ready', {
      socketId: socket.id,
      app: context.container.metadata.appName,
      timestamp: new Date().toISOString()
    });

    socket.on('channel:join', ({ channelId }) => {
      if (!channelId) {
        return;
      }

      socket.join(channelId);
      socket.emit('channel:joined', {
        channelId,
        joinedAt: new Date().toISOString()
      });
    });

    socket.on('chat:message', ({ channelId, content, type = 'text' }) => {
      if (!channelId || !content) {
        return;
      }

      io.to(channelId).emit('chat:message', {
        channelId,
        content,
        type,
        senderId: socket.id,
        timestamp: new Date().toISOString()
      });
    });

    socket.on('location:update', ({ lat, lng, accuracy, timestamp }) => {
      socket.broadcast.emit('presence:update', {
        userId: socket.id,
        lat,
        lng,
        accuracy,
        timestamp
      });
    });

    socket.on('territory:claim', ({ path = [], sessionId = null }) => {
      socket.emit('territory:queued', {
        sessionId,
        pointCount: path.length,
        status: 'accepted-for-processing'
      });
    });
  });
}

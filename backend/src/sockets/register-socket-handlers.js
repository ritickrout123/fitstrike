export function registerSocketHandlers(io, context) {
  const { squadService } = context.container;

  io.on('connection', (socket) => {
    socket.emit('session:ready', {
      socketId: socket.id,
      app: context.container.metadata.appName,
      timestamp: new Date().toISOString()
    });

    // --- Social / Chat ---
    socket.on('channel:join', ({ channelId }) => {
      if (!channelId) return;
      socket.join(channelId);
      socket.emit('channel:joined', { channelId, joinedAt: new Date().toISOString() });
    });

    socket.on('chat:message', ({ channelId, content, type = 'text' }) => {
      if (!channelId || !content) return;
      io.to(channelId).emit('chat:message', {
        channelId,
        content,
        type,
        senderId: socket.id,
        timestamp: new Date().toISOString()
      });
    });

    // --- Squads & Matchmaking ---
    socket.on('squad:join', async ({ squadId }) => {
      if (!squadId) return;
      socket.join(`squad:${squadId}`);
      socket.emit('squad:joined', { squadId });
    });

    // --- Streaming & WebRTC Signaling ---
    socket.on('stream:join', ({ streamId }) => {
      if (!streamId) return;
      socket.join(`stream:${streamId}`);
      socket.emit('stream:joined', { streamId });
    });

    socket.on('stream:transport:create', async ({ streamId, direction }, callback) => {
      try {
        const transportParams = await context.container.streamingService.createTransport(streamId, direction);
        callback(transportParams);
      } catch (err) {
        callback({ error: err.message });
      }
    });

    socket.on('stream:transport:connect', async ({ transportId, dtlsParameters }, callback) => {
      // Logic to connect transport in service would be needed if we tracked transport objects in service
      // For now, we assume simple-peer or client-side handling if possible, or we'd need to extend service
      callback({ status: 'connected' });
    });

    socket.on('stream:produce', async ({ streamId, transportId, kind, rtpParameters }, callback) => {
      // Signaling logic to start producing
      socket.to(`stream:${streamId}`).emit('stream:new-producer', { streamId, kind });
      callback({ id: `prod_${Date.now()}` });
    });

    // --- Presence & Gameplay ---
    socket.on('location:update', ({ lat, lng, accuracy, userId }) => {
      // Use real userId if provided
      const id = userId || socket.id;
      socket.broadcast.emit('presence:update', {
        userId: id,
        lat,
        lng,
        accuracy,
        timestamp: new Date().toISOString()
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

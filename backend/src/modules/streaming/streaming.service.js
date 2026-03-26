import mediasoup from 'mediasoup';
import { mediasoupConfig } from '../../config/mediasoup.js';
import { HttpError } from '../../lib/http-error.js';

export async function createStreamingService({ redisService, env }) {
  const workers = [];
  let nextWorkerIndex = 0;

  // Initialize workers
  for (let i = 0; i < mediasoupConfig.workers.numWorkers; i++) {
    const worker = await mediasoup.createWorker(mediasoupConfig.workers);
    
    worker.on('died', () => {
      console.error('mediasoup worker died, exiting in 2 seconds... [pid:%d]', worker.pid);
      setTimeout(() => process.exit(1), 2000);
    });

    workers.push(worker);
  }

  function getNextWorker() {
    const worker = workers[nextWorkerIndex];
    nextWorkerIndex = (nextWorkerIndex + 1) % workers.length;
    return worker;
  }

  // Active routers map: streamId -> router
  const routers = new Map();
  // Active producers map: streamId -> producer
  const producers = new Map();

  async function startStream(userId, activityId) {
    const worker = getNextWorker();
    const router = await worker.createRouter(mediasoupConfig.router);
    const streamId = `stream_${Date.now()}`;

    routers.set(streamId, router);

    // Store metadata in Redis
    await redisService.redis.hset(`stream:${streamId}`, {
      id: streamId,
      userId,
      activityId,
      startTime: Date.now(),
      viewers: 0
    });

    // Add to active streams list
    await redisService.redis.sadd('streams:live', streamId);

    return {
      streamId,
      rtpCapabilities: router.rtpCapabilities
    };
  }

  async function stopStream(streamId) {
    const router = routers.get(streamId);
    if (router) {
      router.close();
      routers.delete(streamId);
    }
    producers.delete(streamId);
    await redisService.redis.del(`stream:${streamId}`);
    await redisService.redis.srem('streams:live', streamId);
  }

  async function createTransport(streamId, direction) {
    const router = routers.get(streamId);
    if (!router) throw new HttpError(404, 'STREAM_NOT_FOUND', 'Stream not found.');

    const transport = await router.createWebRtcTransport(mediasoupConfig.webRtcTransport);

    transport.on('dtlsstatechange', (dtlsState) => {
      if (dtlsState === 'closed') transport.close();
    });

    return {
      id: transport.id,
      iceParameters: transport.iceParameters,
      iceCandidates: transport.iceCandidates,
      dtlsParameters: transport.dtlsParameters
    };
  }

  return {
    startStream,
    stopStream,
    createTransport,
    getLiveStreams: async () => redisService.redis.smembers('streams:live')
  };
}

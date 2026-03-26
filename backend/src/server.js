import http from 'node:http';
import { Server } from 'socket.io';

import { createApp } from './app.js';
import { env } from './config/env.js';
import { connectDatabases } from './config/database.js';
import { initPostGIS } from './config/postgis.js';
import { createServiceContainer } from './services/container.js';
import { registerSocketHandlers } from './sockets/register-socket-handlers.js';

async function startServer() {
  console.log(`🚀 Starting ${env.appName}...`);

  // 1. Connect Databases
  const { redisClient, pgPool } = await connectDatabases(env);

  // 2. Run Migrations
  await initPostGIS(pgPool);

  // 3. Initialize Container
  const container = await createServiceContainer(env, { redisClient, pgPool });

  // 4. Create App
  const app = createApp(container, env);
  const server = http.createServer(app);

  // 5. Setup Sockets
  const io = new Server(server, {
    cors: {
      origin: buildSocketCorsOriginChecker(env),
      credentials: true
    }
  });

  registerSocketHandlers(io, { container });

  // 6. Start Listening
  server.listen(env.port, () => {
    console.log(`✅ FitStrike backend ready on port ${env.port}`);
  });

  // Handle Shutdown
  function shutdown(signal) {
    console.log(`Received ${signal}, shutting down FitStrike API...`);

    io.close(async () => {
      await redisClient.quit();
      await pgPool.end();
      server.close(() => {
        process.exit(0);
      });
    });
  }

  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

function buildSocketCorsOriginChecker(env) {
  return (origin, callback) => {
    if (!origin) {
      callback(null, true);
      return;
    }

    if (
      env.socketCorsOrigins.includes('*') ||
      env.socketCorsOrigins.includes(origin) ||
      (env.nodeEnv === 'development' &&
        /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin))
    ) {
      callback(null, true);
      return;
    }

    callback(new Error(`Socket origin not allowed: ${origin}`));
  };
}

startServer().catch((err) => {
  console.error('💥 Failed to start server:', err);
  process.exit(1);
});

import http from 'node:http';

import { Server } from 'socket.io';

import { createApp } from './app.js';
import { env } from './config/env.js';
import { createServiceContainer } from './services/container.js';
import { registerSocketHandlers } from './sockets/register-socket-handlers.js';

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

const container = createServiceContainer(env);
const app = createApp(container, env);
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: buildSocketCorsOriginChecker(env),
    credentials: true
  }
});

registerSocketHandlers(io, { container });

server.listen(env.port, () => {
  console.log(`${env.appName} listening on port ${env.port}`);
});

function shutdown(signal) {
  console.log(`Received ${signal}, shutting down FitStrike API...`);

  io.close(() => {
    server.close(() => {
      process.exit(0);
    });
  });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

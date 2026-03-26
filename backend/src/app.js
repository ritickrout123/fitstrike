import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { buildApiRouter } from './routes/index.js';

function isDevelopmentLocalOrigin(origin, env) {
  if (env.nodeEnv !== 'development' || !origin) {
    return false;
  }

  return /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
}

function buildCorsOriginChecker(env) {
  return (origin, callback) => {
    if (!origin) {
      callback(null, true);
      return;
    }

    if (env.corsOrigins.includes('*') || env.corsOrigins.includes(origin)) {
      callback(null, true);
      return;
    }

    if (isDevelopmentLocalOrigin(origin, env)) {
      callback(null, true);
      return;
    }

    callback(new Error(`CORS origin not allowed: ${origin}`));
  };
}

export function createApp(container, env) {
  const app = express();

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(
    cors({
      origin: buildCorsOriginChecker(env),
      credentials: true
    })
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(morgan(env.nodeEnv === 'development' ? 'dev' : 'combined'));

  app.get('/', (_request, response) => {
    response.json({
      name: container.metadata.appName,
      version: container.metadata.version,
      status: 'ok',
      docs: {
        product: '/docs/FitStrikeDELIVERABLE1.md',
        architecture: '/docs/FitStrikeDELIVERABLES2.md',
        prototype: '/docs/fitstrike.html'
      }
    });
  });

  app.use('/v1', buildApiRouter(container));

  app.use((_request, response) => {
    response.status(404).json({
      error: 'NOT_FOUND',
      message: 'The requested route does not exist yet.'
    });
  });

  app.use((error, _request, response, _next) => {
    console.error(error);
    response.status(error.statusCode ?? 500).json({
      error: error.code ?? 'INTERNAL_SERVER_ERROR',
      message: error.message ?? 'Something went wrong while processing the request.'
    });
  });

  return app;
}

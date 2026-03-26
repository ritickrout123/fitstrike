import dotenv from 'dotenv';

dotenv.config();

function readEnv(name, fallback) {
  return process.env[name] ?? fallback;
}

function parseOrigins(value, fallback) {
  const raw = readEnv(value, fallback);

  return raw
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

export const env = {
  nodeEnv: readEnv('NODE_ENV', 'development'),
  port: Number(readEnv('PORT', '3000')),
  appName: readEnv('APP_NAME', 'FitStrike API'),
  corsOrigin: readEnv('CORS_ORIGIN', 'http://localhost:3001'),
  socketCorsOrigin: readEnv('SOCKET_CORS_ORIGIN', 'http://localhost:3001'),
  corsOrigins: parseOrigins('CORS_ORIGIN', 'http://localhost:3001'),
  socketCorsOrigins: parseOrigins('SOCKET_CORS_ORIGIN', 'http://localhost:3001'),
  mongoUri: readEnv('MONGO_URI', 'mongodb://localhost:27017/fitstrike'),
  redisUri: readEnv('REDIS_URI', 'redis://localhost:6379'),
  postgisUri: readEnv(
    'POSTGIS_URI',
    'postgresql://fitstrike:fitstrike@localhost:5432/fitstrike_geo'
  ),
  jwtSecret: readEnv('JWT_SECRET', 'dev-jwt-secret'),
  jwtRefreshSecret: readEnv('JWT_REFRESH_SECRET', 'dev-refresh-secret'),
  razorpayKeyId: readEnv('RAZORPAY_KEY_ID', ''),
  razorpayKeySecret: readEnv('RAZORPAY_KEY_SECRET', '')
};

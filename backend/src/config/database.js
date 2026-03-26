import mongoose from 'mongoose';
import Redis from 'ioredis';
import pg from 'pg';

export async function connectDatabases(env) {
  // 1. MongoDB via Mongoose
  try {
    await mongoose.connect(env.mongoUri, {
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 10000,
    });
    console.log('✅ MongoDB connected successfully');
    
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB error:', err.message);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️ MongoDB disconnected. Attempting to reconnect...');
    });
  } catch (err) {
    console.error('❌ MongoDB connection failed:', err.message);
  }

  // 2. Redis via ioredis
  const redisClient = new Redis(env.redisUri, {
    maxRetriesPerRequest: null,
    enableReadyCheck: true,
    connectTimeout: 5000,
    retryStrategy(times) {
      const delay = Math.min(times * 100, 2000);
      return delay;
    }
  });

  redisClient.on('connect', () => console.log('✅ Redis connected successfully'));
  redisClient.on('error', (err) => console.error('❌ Redis error:', err.message));

  // 3. PostgreSQL via pg
  const pgPool = new pg.Pool({
    connectionString: env.postgisUri,
    connectionTimeoutMillis: 5000,
    idleTimeoutMillis: 30000,
    max: 20
  });

  pgPool.on('connect', () => console.log('✅ PostgreSQL/PostGIS connected successfully'));
  pgPool.on('error', (err) => console.error('❌ PostgreSQL error:', err.message));

  return {
    mongooseConnection: mongoose.connection,
    redisClient,
    pgPool
  };
}

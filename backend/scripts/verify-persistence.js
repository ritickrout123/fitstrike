import mongoose from 'mongoose';
import Redis from 'ioredis';
import pg from 'pg';
import { env } from '../src/config/env.js';

async function verify() {
  console.log('🧪 Verifying Production Persistence...');

  // 1. MongoDB
  try {
    await mongoose.connect(env.mongoUri);
    console.log('✅ MongoDB: CONNECTED');
    await mongoose.disconnect();
  } catch (err) {
    console.error('❌ MongoDB: FAILED', err.message);
  }

  // 2. Redis
  const redis = new Redis(env.redisUri);
  try {
    await redis.set('test-key', 'ok', 'EX', 10);
    const val = await redis.get('test-key');
    console.log('✅ Redis: CONNECTED (Test key:', val, ')');
    await redis.quit();
  } catch (err) {
    console.error('❌ Redis: FAILED', err.message);
  }

  // 3. PostGIS
  const pgPool = new pg.Pool({ connectionString: env.postgisUri });
  try {
    const res = await pgPool.query('SELECT postgis_version();');
    console.log('✅ PostGIS: CONNECTED (Version:', res.rows[0].postgis_version, ')');
    await pgPool.end();
  } catch (err) {
    console.error('❌ PostGIS: FAILED', err.message);
  }
}

verify();

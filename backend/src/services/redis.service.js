export class RedisService {
  constructor(redisClient) {
    this.redis = redisClient;
  }

  // --- Leaderboard Methods (Sorted Sets) ---
  
  async addToLeaderboard(board, userId, score) {
    // board: 'leaderboard:global:xp', 'leaderboard:global:area', etc.
    return this.redis.zadd(board, score, userId);
  }

  async getLeaderboardRange(board, start, end) {
    // Returns userIds and scores
    return this.redis.zrevrange(board, start, end, 'WITHSCORES');
  }

  async getUserRank(board, userId) {
    const rank = await this.redis.zrevrank(board, userId);
    return rank !== null ? rank + 1 : null; // 1-indexed
  }

  async getUserScore(board, userId) {
    const score = await this.redis.zscore(board, userId);
    return score !== null ? parseFloat(score) : 0;
  }

  // --- Online Presence Methods ---

  async setOnline(userId, lat, lng) {
    const multi = this.redis.multi();
    
    // Add to online set
    multi.sadd('presence:online', userId);
    
    // Store location with TTL (60s)
    multi.set(
      `presence:location:${userId}`, 
      JSON.stringify({ lat, lng, updatedAt: Date.now() }), 
      'EX', 60
    );
    
    return multi.exec();
  }

  async setOffline(userId) {
    const multi = this.redis.multi();
    multi.srem('presence:online', userId);
    multi.del(`presence:location:${userId}`);
    return multi.exec();
  }

  async getOnlineUsers() {
    return this.redis.smembers('presence:online');
  }

  async getNearbyUsers(lat, lng, radiusKm) {
    // This is a naive implementation using simple distance. 
    // In production, GEOADD/GEORADIUS would be used.
    const onlineUserIds = await this.getOnlineUsers();
    const nearby = [];

    for (const userId of onlineUserIds) {
      const locStr = await this.redis.get(`presence:location:${userId}`);
      if (locStr) {
        const loc = JSON.parse(locStr);
        const distance = this._calculateDistance(lat, lng, loc.lat, loc.lng);
        if (distance <= radiusKm) {
          nearby.push({ userId, ...loc, distance });
        }
      }
    }
    return nearby;
  }

  // --- Cache Methods ---

  async cacheViewport(geohash, territories) {
    return this.redis.set(
      `territory:viewport:${geohash}`, 
      JSON.stringify(territories), 
      'EX', 300 // 5 minutes TTL
    );
  }

  async getCachedViewport(geohash) {
    const data = await this.redis.get(`territory:viewport:${geohash}`);
    return data ? JSON.parse(data) : null;
  }

  async invalidateViewport(geohash) {
    return this.redis.del(`territory:viewport:${geohash}`);
  }

  // --- Rate Limiting ---

  async checkRateLimit(key, maxRequests, windowSeconds) {
    const current = await this.redis.incr(key);
    if (current === 1) {
      await this.redis.expire(key, windowSeconds);
    }
    return current <= maxRequests;
  }

  // --- Run Session State ---

  async saveRunState(sessionId, state) {
    return this.redis.set(
      `game:run:${sessionId}`, 
      JSON.stringify(state), 
      'EX', 3600 * 4 // 4 hours TTL
    );
  }

  async getRunState(sessionId) {
    const data = await this.redis.get(`game:run:${sessionId}`);
    return data ? JSON.parse(data) : null;
  }

  async deleteRunState(sessionId) {
    return this.redis.del(`game:run:${sessionId}`);
  }

  // --- Auth Session Methods ---

  async saveAuthSession(userId, sessionData, ttlSeconds = 900) {
    return this.redis.set(
      `auth:session:${userId}`,
      JSON.stringify(sessionData),
      'EX', ttlSeconds
    );
  }

  async getAuthSession(userId) {
    const data = await this.redis.get(`auth:session:${userId}`);
    return data ? JSON.parse(data) : null;
  }

  async saveRefreshToken(userId, token, ttlSeconds = 604800) {
    return this.redis.set(
      `auth:refresh:${userId}`,
      token,
      'EX', ttlSeconds
    );
  }

  async getRefreshToken(userId) {
    return this.redis.get(`auth:refresh:${userId}`);
  }

  // --- Helper Methods ---

  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}

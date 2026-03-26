import { randomUUID } from 'node:crypto';
import jwt from 'jsonwebtoken';

import { HttpError } from '../../lib/http-error.js';

export function createAuthService({ User, redisService, userService, env }) {
  function createFoundationToday() {
    return {
      date: new Date().toISOString().slice(0, 10),
      streak: 0,
      workout: {
        label: 'Foundation Day',
        focus: 'Complete your first session',
        exercises: [
          {
            id: 'bodyweight-squat',
            name: 'Bodyweight Squat',
            targetSets: 3,
            repRange: '12-15',
            loadKg: 0,
            restSeconds: 45,
            isCompleted: false
          },
          {
            id: 'push-up',
            name: 'Push-Up',
            targetSets: 3,
            repRange: '8-12',
            loadKg: 0,
            restSeconds: 45,
            isCompleted: false
          },
          {
            id: 'plank-hold',
            name: 'Plank Hold',
            targetSets: 3,
            repRange: '30-45 sec',
            loadKg: 0,
            restSeconds: 30,
            isCompleted: false
          }
        ],
        completedAt: null
      },
      nutrition: {
        caloriesGoal: 2200,
        macros: {
          protein: { goal: 150 },
          carbs: { goal: 220 },
          fats: { goal: 60 }
        },
        meals: []
      },
      missions: []
    };
  }

  async function createSession(userId) {
    const accessToken = jwt.sign({ userId }, env.jwtSecret, { expiresIn: '15m' });
    const refreshToken = randomUUID();

    // Store access token in Redis (15 mins) and refresh token (7 days)
    await redisService.saveAuthSession(userId, { accessToken }, 900);
    await redisService.saveRefreshToken(userId, refreshToken, 604800);

    return {
      token: accessToken,
      refreshToken,
      expiresAt: new Date(Date.now() + 15 * 60 * 1000).toISOString()
    };
  }

  async function getSessionByToken(token) {
    if (!token) return null;

    try {
      const decoded = jwt.verify(token, env.jwtSecret);
      const session = await redisService.getAuthSession(decoded.userId);

      if (!session || session.accessToken !== token) {
        return null;
      }

      const user = await User.findOne({ id: decoded.userId }).lean();
      if (!user) return null;

      return {
        token,
        userId: user.id,
        user: userService.toPublicUser(user)
      };
    } catch (err) {
      return null;
    }
  }

  async function getSessionFromHeader(headerValue) {
    if (!headerValue || !headerValue.startsWith('Bearer ')) {
      return null;
    }

    const token = headerValue.replace('Bearer ', '').trim();
    return getSessionByToken(token);
  }

  async function register({ username, email, password, displayName }) {
    if (!username || !email || !password) {
      throw new HttpError(400, 'AUTH_INVALID_PAYLOAD', 'Username, email, and password are required.');
    }

    const existingEmail = await User.findOne({ email: email.toLowerCase() });
    if (existingEmail) {
      throw new HttpError(409, 'AUTH_EMAIL_EXISTS', 'An account with that email already exists.');
    }

    const existingUsername = await User.findOne({ username: username.toLowerCase() });
    if (existingUsername) {
      throw new HttpError(409, 'AUTH_USERNAME_EXISTS', 'That username is already taken.');
    }

    const user = new User({
      username: username.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: password, // Pre-save hook will hash it
      profile: {
        displayName: displayName?.trim() || username.trim(),
        level: 1,
        title: 'Rookie Striker'
      },
      today: createFoundationToday()
    });

    await user.save();

    return {
      session: await createSession(user.id),
      user: userService.toPublicUser(user)
    };
  }

  async function login({ email, password }) {
    if (!email || !password) {
      throw new HttpError(400, 'AUTH_INVALID_PAYLOAD', 'Email and password are required.');
    }

    const user = await User.findByEmail(email);

    if (!user || !(await user.comparePassword(password))) {
      throw new HttpError(401, 'AUTH_INVALID_CREDENTIALS', 'Invalid email or password.');
    }

    return {
      session: await createSession(user.id),
      user: userService.toPublicUser(user)
    };
  }

  return {
    getSessionByToken,
    getSessionFromHeader,
    login,
    register
  };
}

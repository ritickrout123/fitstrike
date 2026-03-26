import { randomUUID } from 'node:crypto';

import { HttpError } from '../../lib/http-error.js';
import { createSessionToken, hashPassword, verifyPassword } from '../../lib/security.js';

export function createAuthService(store, userService) {
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

  function findUserByEmail(email) {
    const normalizedEmail = email.trim().toLowerCase();
    return [...store.users.values()].find((user) => user.email.toLowerCase() === normalizedEmail);
  }

  function findUserByUsername(username) {
    const normalizedUsername = username.trim().toLowerCase();
    return [...store.users.values()].find(
      (user) => user.username.toLowerCase() === normalizedUsername
    );
  }

  function createSession(userId) {
    const token = createSessionToken();
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7).toISOString();

    store.sessions.set(token, {
      token,
      userId,
      createdAt: new Date().toISOString(),
      expiresAt
    });

    return {
      token,
      expiresAt
    };
  }

  function getSessionByToken(token) {
    if (!token) {
      return null;
    }

    const session = store.sessions.get(token);

    if (!session) {
      return null;
    }

    if (Date.parse(session.expiresAt) <= Date.now()) {
      store.sessions.delete(token);
      return null;
    }

    const user = store.users.get(session.userId);

    if (!user) {
      store.sessions.delete(token);
      return null;
    }

    return {
      ...session,
      user: userService.toPublicUser(user)
    };
  }

  function getSessionFromHeader(headerValue) {
    if (!headerValue || !headerValue.startsWith('Bearer ')) {
      return null;
    }

    const token = headerValue.replace('Bearer ', '').trim();
    return getSessionByToken(token);
  }

  function register({ username, email, password, displayName }) {
    if (!username || !email || !password) {
      throw new HttpError(400, 'AUTH_INVALID_PAYLOAD', 'Username, email, and password are required.');
    }

    if (findUserByEmail(email)) {
      throw new HttpError(409, 'AUTH_EMAIL_EXISTS', 'An account with that email already exists.');
    }

    if (findUserByUsername(username)) {
      throw new HttpError(409, 'AUTH_USERNAME_EXISTS', 'That username is already taken.');
    }

    const userId = `user_${randomUUID()}`;
    const user = {
      id: userId,
      username: username.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: hashPassword(password),
      profile: {
        displayName: displayName?.trim() || username.trim(),
        level: 1,
        title: 'Rookie Striker'
      },
      stats: {
        totalDistance: 0,
        totalArea: 0,
        workoutsCompleted: 0,
        territoryCaptures: 0
      },
      today: createFoundationToday()
    };

    store.users.set(user.id, user);

    return {
      session: createSession(user.id),
      user: userService.toPublicUser(user)
    };
  }

  function login({ email, password }) {
    if (!email || !password) {
      throw new HttpError(400, 'AUTH_INVALID_PAYLOAD', 'Email and password are required.');
    }

    const user = findUserByEmail(email);

    if (!user || !verifyPassword(password, user.passwordHash)) {
      throw new HttpError(401, 'AUTH_INVALID_CREDENTIALS', 'Invalid email or password.');
    }

    return {
      session: createSession(user.id),
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

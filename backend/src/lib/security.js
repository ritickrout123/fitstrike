import { randomBytes } from 'node:crypto';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export async function hashPassword(password) {
  return await bcrypt.hash(password, 12);
}

export async function verifyPassword(password, passwordHash) {
  return await bcrypt.compare(password, passwordHash);
}

export function createSessionToken() {
  return randomBytes(32).toString('hex');
}

export function generateJwt(userId, secret, expires) {
  return jwt.sign({ userId }, secret, { expiresIn: expires });
}

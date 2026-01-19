// src/utils/jwt.ts
import jwt from 'jsonwebtoken';
import logger from '../config/logger';

export interface JwtPayload {
  id: string;
  email: string;
}

const JWT_SECRET = process.env.JWT_SECRET || 'secret';
const JWT_EXPIRES_IN = '1d';

export const signToken = (payload: JwtPayload): string => {
  try {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
  } catch (e) {
    logger.error('Failed to authenticate token', e);
    throw new Error('Failed to authenticate token');
  }
};

export const verifyToken = (token: string) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (e) {
    logger.error('Failed to authenticate token', e);
    throw new Error('Failed to authenticate token');
  }
};

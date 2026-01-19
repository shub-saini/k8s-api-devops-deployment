import type { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../utils/jwt';
import logger from '../config/logger';
import type { JwtPayload } from '../utils/jwt';

export default function auth(req: Request, res: Response, next: NextFunction) {
  try {
    const token = req.cookies?.token;

    if (!token) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const decoded = verifyToken(token) as JwtPayload;
    req.user = decoded;

    logger.info(`User authenticated: ${decoded.email}`);
    next();
  } catch {
    res.status(401).json({ error: 'Invalid token' });
  }
}

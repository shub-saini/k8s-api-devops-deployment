import type { Request, Response, NextFunction } from 'express';
import logger from '../config/logger';

export default function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
) {
  logger.error('Request failed', {
    message: err.message,
    path: req.path,
  });

  res.status(400).json({ error: err.message });
}

// src/modules/auth/auth.controller.ts
import type { Request, Response, NextFunction } from 'express';
import * as service from './auth.service';
import { authSchema } from '../../validations/auth.validation';
import logger from '../../config/logger';
import { signToken } from '../../utils/jwt';

export const register = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const validateUser = authSchema.safeParse(req.body);

    if (!validateUser.success) {
      return res.status(400).json({
        error: 'Validation failed',
        details: validateUser.error,
      });
    }

    const { email, password } = validateUser.data;

    const user = await service.register(email, password);

    const token = signToken({ id: user.id, email });
    res.cookie('token', token, { maxAge: 15 * 60 * 1000 });

    logger.info(`User registered successfully: ${email}`);
    res.status(200).json({
      message: 'User registered',
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (err) {
    next(err);
  }
};

export const login = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const validateUser = authSchema.safeParse(req.body);

    if (!validateUser.success) {
      return res.status(400).json({
        error: 'Validation failed',
        details: validateUser.error,
      });
    }

    const { email, password } = validateUser.data;

    const user = await service.login(email, password);

    const token = signToken({ id: user.id, email });
    res.cookie('token', token, { maxAge: 15 * 60 * 1000 });

    logger.info(`User loggedin successfully: ${email}`);
    res.status(200).json({
      message: 'User Autenticated',
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (err) {
    next(err);
  }
};

export const signOut = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    res.clearCookie('token');

    logger.info('User signed out successfully');
    res.status(200).json({
      message: 'User signed out successfully',
    });
  } catch (e) {
    logger.error('Sign out error', e);
    next(e);
  }
};

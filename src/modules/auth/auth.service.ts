// src/modules/auth/auth.service.ts
import bcrypt from 'bcryptjs';
import prisma from '../../config/prisma';
import { signToken } from '../../utils/jwt';
import logger from '../../config/logger';

export const register = async (email: string, password: string) => {
  try {
    const hash = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: { email, password: hash },
    });

    logger.info(`User ${user.email} created successfully`);

    return user;
  } catch (e) {
    logger.error(`Error creating the user: ${e}`);
    throw e;
  }
};

export const login = async (email: string, password: string) => {
  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) throw new Error('Invalid credentials');

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) throw new Error('Invalid credentials');

    logger.info(`User ${user.email} authenticated successfully`);

    return user;
  } catch (e) {
    logger.error(`Error authenticating user: ${e}`);
    throw e;
  }
};

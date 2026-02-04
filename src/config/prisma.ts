import dotenv from 'dotenv';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client';

if (process.env.NODE_ENV !== 'prod') {
  dotenv.config({
    path: '.env.local',
  });
}

const connectionString = process.env.DATABASE_URL!;
if (!connectionString) {
  throw new Error('DATABASE_URL is missing');
}

const adapter = new PrismaPg({ connectionString });

const prisma = new PrismaClient({ adapter });

export async function testConnection() {
  try {
    await prisma.$connect();
    return { status: 'connected' };
  } catch (error) {
    return { status: 'failed', error };
  }
}

export default prisma;

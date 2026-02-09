import dotenv from 'dotenv';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client';
import { existsSync } from 'fs';

const isProduction = process.env.NODE_ENV === 'production';

if (isProduction) {
  if (existsSync('.env')) {
    dotenv.config({ path: '.env', override: true });
  }
} else {
  dotenv.config({ path: '.env.local', override: true });
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

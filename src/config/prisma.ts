import dotenv from 'dotenv';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaNeon } from '@prisma/adapter-neon';
import { PrismaClient } from '../../generated/prisma/client';

const NODE_ENV = process.env.NODE_ENV ?? 'local';
dotenv.config({
  path: process.env.NODE_ENV === 'prod' ? '.env' : '.env.local',
  override: true,
});

const connectionString = process.env.DATABASE_URL!;
if (!connectionString) {
  throw new Error('DATABASE_URL is missing');
}
console.log(connectionString);

const adapter =
  NODE_ENV === 'prod'
    ? new PrismaNeon({ connectionString })
    : new PrismaPg({ connectionString });

const prisma = new PrismaClient({ adapter });

// In a health check endpoint
export async function testConnection() {
  try {
    await prisma.$connect();
    return { status: 'connected' };
  } catch (error) {
    return { status: 'failed', error };
  }
}

export default prisma;

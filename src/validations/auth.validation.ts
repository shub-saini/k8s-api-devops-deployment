import { z } from 'zod';

export const authSchema = z.object({
  email: z.string().min(2).max(256).trim(),
  password: z.string().min(6).max(128),
});

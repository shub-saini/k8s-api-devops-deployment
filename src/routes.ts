// src/routes.ts
import { Router } from 'express';
import authRoutes from './modules/auth/auth.routes';
import todoRoutes from './modules/todo/todo.routes';
import authMiddleware from './middlewares/auth.middleware';

const router = Router();

router.use('/auth', authRoutes);
router.use('/todos', authMiddleware, todoRoutes);

export default router;

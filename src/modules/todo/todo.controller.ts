import type { Request, Response, NextFunction } from 'express';
import * as service from './todo.service';

export const create = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const todo = await service.createTodo(req.user!.id, req.body.title);
    res.json(todo);
  } catch (err) {
    next(err);
  }
};

export const list = async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json(await service.listTodos(req.user!.id));
  } catch (err) {
    next(err);
  }
};

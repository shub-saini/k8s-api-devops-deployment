import prisma from '../../config/prisma';

export const createTodo = (userId: string, title: string) =>
  prisma.todo.create({
    data: { title, userId },
  });

export const listTodos = (userId: string) =>
  prisma.todo.findMany({
    where: { userId },
  });

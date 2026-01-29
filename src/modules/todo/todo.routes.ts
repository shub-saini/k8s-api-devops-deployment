import { Router } from 'express';
import * as controller from './todo.controller';

const router = Router();

router.get('/', controller.list);
router.post('/', controller.create);

export default router;

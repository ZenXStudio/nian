import { Router } from 'express';
import { addUserMethod, getUserMethods, updateUserMethod, deleteUserMethod } from '../controllers/userMethod.controller';
import { authenticateUser } from '../middleware/auth';

const router = Router();

// 所有路由都需要认证
router.use(authenticateUser);

// 添加方法到个人库
router.post('/', addUserMethod);

// 获取个人方法列表
router.get('/', getUserMethods);

// 更新个人方法
router.put('/:id', updateUserMethod);

// 删除个人方法
router.delete('/:id', deleteUserMethod);

export default router;

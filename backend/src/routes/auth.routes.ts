import { Router } from 'express';
import { register, login, getCurrentUser } from '../controllers/auth.controller';
import { authenticateUser } from '../middleware/auth';

const router = Router();

// 用户注册
router.post('/register', register);

// 用户登录
router.post('/login', login);

// 获取当前用户信息（需要认证）
router.get('/me', authenticateUser, getCurrentUser);

export default router;

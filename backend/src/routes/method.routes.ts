import { Router } from 'express';
import { getMethods, getMethodById, getRecommendedMethods, getCategories } from '../controllers/method.controller';
import { authenticateUser } from '../middleware/auth';

const router = Router();

// 获取方法列表（支持筛选和搜索）
router.get('/', getMethods);

// 获取方法分类列表
router.get('/categories', getCategories);

// 获取推荐方法（需要认证）
router.get('/recommend', authenticateUser, getRecommendedMethods);

// 获取方法详情
router.get('/:id', getMethodById);

export default router;

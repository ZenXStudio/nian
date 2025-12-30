import { Router } from 'express';
import { createPracticeRecord, getPracticeHistory, getPracticeStatistics } from '../controllers/practice.controller';
import { authenticateUser } from '../middleware/auth';

const router = Router();

// 所有路由都需要认证
router.use(authenticateUser);

// 记录练习
router.post('/', createPracticeRecord);

// 获取练习历史
router.get('/', getPracticeHistory);

// 获取练习统计
router.get('/statistics', getPracticeStatistics);

export default router;

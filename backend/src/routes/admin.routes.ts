import { Router } from 'express';
import {
  adminLogin,
  getAllMethods,
  createMethod,
  updateMethod,
  deleteMethod,
  submitForReview,
  approveMethod,
  rejectMethod,
  getUserStatistics,
  getMethodStatistics,
} from '../controllers/admin.controller';
import { authenticateAdmin } from '../middleware/auth';

const router = Router();

// 管理员登录（不需要认证）
router.post('/login', adminLogin);

// 以下路由都需要管理员认证
router.use(authenticateAdmin);

// 方法管理
router.get('/methods', getAllMethods);
router.post('/methods', createMethod);
router.put('/methods/:id', updateMethod);
router.delete('/methods/:id', deleteMethod);

// 内容审核
router.post('/methods/:id/submit', submitForReview);
router.post('/methods/:id/approve', approveMethod);
router.post('/methods/:id/reject', rejectMethod);

// 数据统计
router.get('/statistics/users', getUserStatistics);
router.get('/statistics/methods', getMethodStatistics);

export default router;

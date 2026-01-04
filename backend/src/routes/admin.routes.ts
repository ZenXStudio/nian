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
  uploadFile,
  getMediaFiles,
  deleteMediaFile,
  exportUsers,
  exportMethods,
  exportPractices,
  getUsers,
  getUserDetail,
  updateUserStatus,
  getUserMethods,
  getUserPractices,
} from '../controllers/admin.controller';
import { authenticateAdmin } from '../middleware/auth';
import { upload } from '../utils/upload';

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

// 文件上传和媒体管理
router.post('/upload', upload.single('file'), uploadFile);
router.get('/media', getMediaFiles);
router.delete('/media/:id', deleteMediaFile);

// 数据导出
router.get('/export/users', exportUsers);
router.get('/export/methods', exportMethods);
router.get('/export/practices', exportPractices);

// 用户管理
router.get('/users', getUsers);
router.get('/users/:id', getUserDetail);
router.put('/users/:id/status', updateUserStatus);
router.get('/users/:id/methods', getUserMethods);
router.get('/users/:id/practices', getUserPractices);

export default router;
router.delete('/methods/:id', deleteMethod);

// 内容审核
router.post('/methods/:id/submit', submitForReview);
router.post('/methods/:id/approve', approveMethod);
router.post('/methods/:id/reject', rejectMethod);

// 数据统计
router.get('/statistics/users', getUserStatistics);
router.get('/statistics/methods', getMethodStatistics);

// 文件上传和媒体管理
router.post('/upload', upload.single('file'), uploadFile);
router.get('/media', getMediaFiles);
router.delete('/media/:id', deleteMediaFile);

// 数据导出
router.get('/export/users', exportUsers);
router.get('/export/methods', exportMethods);
router.get('/export/practices', exportPractices);

// 用户管理
router.get('/users', getUsers);
router.get('/users/:id', getUserDetail);
router.put('/users/:id/status', updateUserStatus);
router.get('/users/:id/methods', getUserMethods);
router.get('/users/:id/practices', getUserPractices);

export default router;

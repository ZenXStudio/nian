import 'dotenv/config';
import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { initializeDatabase, closeDatabaseConnections } from './config/database';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './utils/logger';

// 导入路由
import authRoutes from './routes/auth.routes';
import methodRoutes from './routes/method.routes';
import userMethodRoutes from './routes/userMethod.routes';
import practiceRoutes from './routes/practice.routes';
import adminRoutes from './routes/admin.routes';

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务（上传的文件）
app.use('/uploads', express.static('uploads'));
app.use('/exports', express.static('exports'));

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API路由
app.use('/api/auth', authRoutes);
app.use('/api/methods', methodRoutes);
app.use('/api/user/methods', userMethodRoutes);
app.use('/api/user/practice', practiceRoutes);
app.use('/api/admin', adminRoutes);

// 404处理
app.use((req, res) => {
  res.status(404).json({ success: false, error: { code: 'NOT_FOUND', message: 'Route not found' } });
});

// 错误处理
app.use(errorHandler);

// 启动服务器
async function startServer() {
  try {
    // 初始化数据库连接
    await initializeDatabase();
    
    // 启动HTTP服务器
    app.listen(PORT, () => {
      logger.info(`Server is running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// 优雅关闭
process.on('SIGTERM', async () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  await closeDatabaseConnections();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT signal received: closing HTTP server');
  await closeDatabaseConnections();
  process.exit(0);
});

// 启动
startServer();
startServer();

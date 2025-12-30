import { Pool } from 'pg';
import { createClient } from 'redis';

// PostgreSQL连接池
export const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'mental_app',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Redis客户端
export const redisClient = createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
  },
});

// 初始化数据库连接
export async function initializeDatabase(): Promise<void> {
  try {
    // 测试PostgreSQL连接
    const pgClient = await pool.connect();
    console.log('✓ PostgreSQL connected successfully');
    pgClient.release();

    // 连接Redis
    await redisClient.connect();
    console.log('✓ Redis connected successfully');
  } catch (error) {
    console.error('Database initialization failed:', error);
    throw error;
  }
}

// 优雅关闭连接
export async function closeDatabaseConnections(): Promise<void> {
  await pool.end();
  await redisClient.quit();
  console.log('Database connections closed');
}

import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { pool } from '../config/database';
import { generateToken } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { User, UserWithPassword, AuthRequest } from '../types';

// 用户注册
export const register = async (req: Request, res: Response) => {
  const { email, password, nickname } = req.body;

  // 验证输入
  if (!email || !password) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Email and password are required');
  }

  // 验证邮箱格式
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Invalid email format');
  }

  // 验证密码强度
  if (password.length < 8) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Password must be at least 8 characters');
  }

  // 检查邮箱是否已存在
  const checkResult = await pool.query(
    'SELECT id FROM users WHERE email = $1',
    [email]
  );

  if (checkResult.rows.length > 0) {
    throw new AppError(409, 'DUPLICATE_ENTRY', 'Email already registered');
  }

  // 加密密码
  const password_hash = await bcrypt.hash(password, 10);

  // 创建用户
  const result = await pool.query<UserWithPassword>(
    `INSERT INTO users (email, password_hash, nickname, last_login_at) 
     VALUES ($1, $2, $3, NOW()) 
     RETURNING id, email, nickname, avatar_url, created_at, is_active`,
    [email, password_hash, nickname || null]
  );

  const user = result.rows[0];

  // 生成token
  const token = generateToken({ id: user.id, email: user.email });

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      token,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
      },
    },
  });
};

// 用户登录
export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Email and password are required');
  }

  // 查询用户
  const result = await pool.query<UserWithPassword>(
    'SELECT * FROM users WHERE email = $1',
    [email]
  );

  if (result.rows.length === 0) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid email or password');
  }

  const user = result.rows[0];

  // 检查账号是否激活
  if (!user.is_active) {
    throw new AppError(403, 'PERMISSION_DENIED', 'Account is disabled');
  }

  // 验证密码
  const isPasswordValid = await bcrypt.compare(password, user.password_hash);

  if (!isPasswordValid) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid email or password');
  }

  // 更新最后登录时间
  await pool.query(
    'UPDATE users SET last_login_at = NOW() WHERE id = $1',
    [user.id]
  );

  // 生成token
  const token = generateToken({ id: user.id, email: user.email });

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      token,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
      },
    },
  });
};

// 获取当前用户信息
export const getCurrentUser = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const result = await pool.query<User>(
    `SELECT id, email, nickname, avatar_url, created_at, last_login_at, is_active 
     FROM users WHERE id = $1`,
    [userId]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User not found');
  }

  res.json({
    success: true,
    data: result.rows[0],
  });
};
import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { pool } from '../config/database';
import { generateToken } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { User, UserWithPassword, AuthRequest } from '../types';

// 用户注册
export const register = async (req: Request, res: Response) => {
  const { email, password, nickname } = req.body;

  // 验证输入
  if (!email || !password) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Email and password are required');
  }

  // 验证邮箱格式
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Invalid email format');
  }

  // 验证密码强度
  if (password.length < 8) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Password must be at least 8 characters');
  }

  // 检查邮箱是否已存在
  const checkResult = await pool.query(
    'SELECT id FROM users WHERE email = $1',
    [email]
  );

  if (checkResult.rows.length > 0) {
    throw new AppError(409, 'DUPLICATE_ENTRY', 'Email already registered');
  }

  // 加密密码
  const password_hash = await bcrypt.hash(password, 10);

  // 创建用户
  const result = await pool.query<UserWithPassword>(
    `INSERT INTO users (email, password_hash, nickname, last_login_at) 
     VALUES ($1, $2, $3, NOW()) 
     RETURNING id, email, nickname, avatar_url, created_at, is_active`,
    [email, password_hash, nickname || null]
  );

  const user = result.rows[0];

  // 生成token
  const token = generateToken({ id: user.id, email: user.email });

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      token,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
      },
    },
  });
};

// 用户登录
export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Email and password are required');
  }

  // 查询用户
  const result = await pool.query<UserWithPassword>(
    'SELECT * FROM users WHERE email = $1',
    [email]
  );

  if (result.rows.length === 0) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid email or password');
  }

  const user = result.rows[0];

  // 检查账号是否激活
  if (!user.is_active) {
    throw new AppError(403, 'PERMISSION_DENIED', 'Account is disabled');
  }

  // 验证密码
  const isPasswordValid = await bcrypt.compare(password, user.password_hash);

  if (!isPasswordValid) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid email or password');
  }

  // 更新最后登录时间
  await pool.query(
    'UPDATE users SET last_login_at = NOW() WHERE id = $1',
    [user.id]
  );

  // 生成token
  const token = generateToken({ id: user.id, email: user.email });

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      token,
      user: {
        id: user.id,
        email: user.email,
        nickname: user.nickname,
        avatar_url: user.avatar_url,
        created_at: user.created_at,
      },
    },
  });
};

// 获取当前用户信息
export const getCurrentUser = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const result = await pool.query<User>(
    `SELECT id, email, nickname, avatar_url, created_at, last_login_at, is_active 
     FROM users WHERE id = $1`,
    [userId]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User not found');
  }

  res.json({
    success: true,
    data: result.rows[0],
  });
};

import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { pool } from '../config/database';
import { generateToken } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthRequest, Method, PaginatedResponse } from '../types';

// 管理员登录
export const adminLogin = async (req: Request, res: Response) => {
  const { username, password } = req.body;

  if (!username || !password) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Username and password are required');
  }

  // 查询管理员
  const result = await pool.query(
    'SELECT * FROM admins WHERE username = $1',
    [username]
  );

  if (result.rows.length === 0) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid username or password');
  }

  const admin = result.rows[0];

  if (!admin.is_active) {
    throw new AppError(403, 'PERMISSION_DENIED', 'Account is disabled');
  }

  // 验证密码
  const isPasswordValid = await bcrypt.compare(password, admin.password_hash);

  if (!isPasswordValid) {
    throw new AppError(401, 'AUTH_FAILED', 'Invalid username or password');
  }

  // 更新最后登录时间
  await pool.query(
    'UPDATE admins SET last_login_at = NOW() WHERE id = $1',
    [admin.id]
  );

  // 生成token
  const token = generateToken({
    id: admin.id,
    username: admin.username,
    role: admin.role,
    isAdmin: true,
  });

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      token,
      admin: {
        id: admin.id,
        username: admin.username,
        role: admin.role,
        email: admin.email,
      },
    },
  });
};

// 获取所有方法（含草稿）
export const getAllMethods = async (req: AuthRequest, res: Response) => {
  const {
    status,
    category,
    page = 1,
    pageSize = 20,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (status) {
    conditions.push(`status = $${paramIndex}`);
    params.push(status);
    paramIndex++;
  }

  if (category) {
    conditions.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM methods ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query<Method>(
    `SELECT m.*, a.username as creator_name
     FROM methods m
     LEFT JOIN admins a ON m.created_by = a.id
     ${whereClause}
     ORDER BY m.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  const response: PaginatedResponse<Method> = {
    list: result.rows,
    total,
    page: Number(page),
    pageSize: Number(pageSize),
  };

  res.json({
    success: true,
    data: response,
  });
};

// 创建方法
export const createMethod = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const {
    title,
    description,
    category,
    difficulty,
    duration_minutes,
    cover_image_url,
    content_json,
  } = req.body;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  // 验证必填字段
  if (!title || !description || !category || !difficulty || !duration_minutes || !content_json) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Missing required fields');
  }

  const result = await pool.query(
    `INSERT INTO methods 
     (title, description, category, difficulty, duration_minutes, cover_image_url, content_json, created_by, status)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'draft')
     RETURNING *`,
    [title, description, category, difficulty, duration_minutes, cover_image_url || null, content_json, adminId]
  );

  res.status(201).json({
    success: true,
    message: 'Method created successfully',
    data: result.rows[0],
  });
};

// 更新方法
export const updateMethod = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const {
    title,
    description,
    category,
    difficulty,
    duration_minutes,
    cover_image_url,
    content_json,
  } = req.body;

  const updates: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (title !== undefined) {
    updates.push(`title = $${paramIndex}`);
    params.push(title);
    paramIndex++;
  }

  if (description !== undefined) {
    updates.push(`description = $${paramIndex}`);
    params.push(description);
    paramIndex++;
  }

  if (category !== undefined) {
    updates.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  if (difficulty !== undefined) {
    updates.push(`difficulty = $${paramIndex}`);
    params.push(difficulty);
    paramIndex++;
  }

  if (duration_minutes !== undefined) {
    updates.push(`duration_minutes = $${paramIndex}`);
    params.push(duration_minutes);
    paramIndex++;
  }

  if (cover_image_url !== undefined) {
    updates.push(`cover_image_url = $${paramIndex}`);
    params.push(cover_image_url);
    paramIndex++;
  }

  if (content_json !== undefined) {
    updates.push(`content_json = $${paramIndex}`);
    params.push(content_json);
    paramIndex++;
  }

  if (updates.length === 0) {
    throw new AppError(400, 'VALIDATION_ERROR', 'No fields to update');
  }

  params.push(id);

  const result = await pool.query(
    `UPDATE methods SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
    params
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found');
  }

  res.json({
    success: true,
    message: 'Method updated successfully',
    data: result.rows[0],
  });
};

// 删除方法
export const deleteMethod = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const result = await pool.query(
    'DELETE FROM methods WHERE id = $1 RETURNING id',
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found');
  }

  res.json({
    success: true,
    message: 'Method deleted successfully',
  });
};

// 提交审核
export const submitForReview = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const { id } = req.params;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const result = await pool.query(
    `UPDATE methods SET status = 'pending' WHERE id = $1 AND status = 'draft' RETURNING *`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found or already submitted');
  }

  // 记录审核日志
  await pool.query(
    `INSERT INTO audit_logs (method_id, admin_id, action, status_before, status_after)
     VALUES ($1, $2, 'submit', 'draft', 'pending')`,
    [id, adminId]
  );

  res.json({
    success: true,
    message: 'Method submitted for review',
    data: result.rows[0],
  });
};

// 审核通过
export const approveMethod = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const { id } = req.params;
  const { comment } = req.body;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  // 检查权限（仅super_admin可审核）
  const adminCheck = await pool.query(
    'SELECT role FROM admins WHERE id = $1',
    [adminId]
  );

  if (adminCheck.rows[0]?.role !== 'super_admin') {
    throw new AppError(403, 'PERMISSION_DENIED', 'Only super admin can approve methods');
  }

  const result = await pool.query(
    `UPDATE methods SET status = 'published', published_at = NOW() 
     WHERE id = $1 AND status = 'pending' RETURNING *`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found or not pending review');
  }

  // 记录审核日志
  await pool.query(
    `INSERT INTO audit_logs (method_id, admin_id, action, status_before, status_after, comment)
     VALUES ($1, $2, 'approve', 'pending', 'published', $3)`,
    [id, adminId, comment || null]
  );

  res.json({
    success: true,
    message: 'Method approved and published',
    data: result.rows[0],
  });
};

// 审核拒绝
export const rejectMethod = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const { id } = req.params;
  const { comment } = req.body;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!comment) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Rejection comment is required');
  }

  // 检查权限
  const adminCheck = await pool.query(
    'SELECT role FROM admins WHERE id = $1',
    [adminId]
  );

  if (adminCheck.rows[0]?.role !== 'super_admin') {
    throw new AppError(403, 'PERMISSION_DENIED', 'Only super admin can reject methods');
  }

  const result = await pool.query(
    `UPDATE methods SET status = 'draft' WHERE id = $1 AND status = 'pending' RETURNING *`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found or not pending review');
  }

  // 记录审核日志
  await pool.query(
    `INSERT INTO audit_logs (method_id, admin_id, action, status_before, status_after, comment)
     VALUES ($1, $2, 'reject', 'pending', 'draft', $3)`,
    [id, adminId, comment]
  );

  res.json({
    success: true,
    message: 'Method rejected',
    data: result.rows[0],
  });
};

// 获取用户统计
export const getUserStatistics = async (req: AuthRequest, res: Response) => {
  const { start_date, end_date } = req.query;

  let dateFilter = '';
  const params: any[] = [];
  
  if (start_date && end_date) {
    dateFilter = 'WHERE created_at BETWEEN $1 AND $2';
    params.push(start_date, end_date);
  }

  const totalUsers = await pool.query(
    `SELECT COUNT(*) as total FROM users ${dateFilter}`,
    params
  );

  const activeUsers = await pool.query(
    `SELECT COUNT(DISTINCT user_id) as active 
     FROM practice_records 
     WHERE practice_date >= CURRENT_DATE - INTERVAL '7 days'`
  );

  const newUsers = await pool.query(
    `SELECT COUNT(*) as new 
     FROM users 
     WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'`
  );

  const userTrend = await pool.query(
    `SELECT DATE(created_at) as date, COUNT(*) as count
     FROM users
     WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
     GROUP BY DATE(created_at)
     ORDER BY date`
  );

  res.json({
    success: true,
    data: {
      total_users: parseInt(totalUsers.rows[0].total),
      active_users: parseInt(activeUsers.rows[0].active),
      new_users: parseInt(newUsers.rows[0].new),
      trend: userTrend.rows,
    },
  });
};

// 获取方法统计
export const getMethodStatistics = async (req: AuthRequest, res: Response) => {
  const totalMethods = await pool.query(
    "SELECT COUNT(*) as total FROM methods WHERE status = 'published'"
  );

  const categoryDistribution = await pool.query(
    `SELECT category, COUNT(*) as count
     FROM methods
     WHERE status = 'published'
     GROUP BY category
     ORDER BY count DESC`
  );

  const popularMethods = await pool.query(
    `SELECT id, title, category, select_count, view_count
     FROM methods
     WHERE status = 'published'
     ORDER BY select_count DESC
     LIMIT 10`
  );

  res.json({
    success: true,
    data: {
      total_methods: parseInt(totalMethods.rows[0].total),
      category_distribution: categoryDistribution.rows,
      popular_methods: popularMethods.rows,
    },
  });
};

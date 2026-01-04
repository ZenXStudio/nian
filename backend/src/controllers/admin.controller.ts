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

// ============= 文件上传和媒体管理 =============

// 上传文件
export const uploadFile = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const file = req.file;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!file) {
    throw new AppError(400, 'VALIDATION_ERROR', 'No file uploaded');
  }

  // 获取文件类型
  let fileType: string;
  if (file.mimetype.startsWith('image/')) {
    fileType = 'image';
  } else if (file.mimetype.startsWith('audio/')) {
    fileType = 'audio';
  } else if (file.mimetype.startsWith('video/')) {
    fileType = 'video';
  } else {
    throw new AppError(400, 'INVALID_FILE_TYPE', 'Invalid file type');
  }

  // 生成URL
  const url = `/uploads/${file.filename}`;

  // 保存到数据库
  const result = await pool.query(
    `INSERT INTO media_files 
     (filename, original_name, file_type, mime_type, file_size, file_path, url, uploaded_by)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING *`,
    [file.filename, file.originalname, fileType, file.mimetype, file.size, file.path, url, adminId]
  );

  res.status(201).json({
    success: true,
    message: 'File uploaded successfully',
    data: result.rows[0],
  });
};

// 获取媒体文件列表
export const getMediaFiles = async (req: AuthRequest, res: Response) => {
  const {
    type,
    search,
    page = 1,
    pageSize = 20,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (type && type !== 'all') {
    conditions.push(`file_type = $${paramIndex}`);
    params.push(type);
    paramIndex++;
  }

  if (search) {
    conditions.push(`(filename ILIKE $${paramIndex} OR original_name ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM media_files ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT m.*, a.username as uploaded_by_name
     FROM media_files m
     LEFT JOIN admins a ON m.uploaded_by = a.id
     ${whereClause}
     ORDER BY m.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

// 删除媒体文件
export const deleteMediaFile = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  // 查询文件信息
  const fileResult = await pool.query(
    'SELECT * FROM media_files WHERE id = $1',
    [id]
  );

  if (fileResult.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Media file not found');
  }

  const file = fileResult.rows[0];

  // 删除数据库记录
  await pool.query('DELETE FROM media_files WHERE id = $1', [id]);

  // 删除物理文件
  const fs = require('fs');
  if (fs.existsSync(file.file_path)) {
    fs.unlinkSync(file.file_path);
  }

  res.json({
    success: true,
    message: 'Media file deleted successfully',
  });
};

// ============= 数据导出 =============

// 导出用户数据
export const exportUsers = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', startDate, endDate, status } = req.query;

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (startDate) {
    conditions.push(`created_at >= $${paramIndex}`);
    params.push(startDate);
    paramIndex++;
  }

  if (endDate) {
    conditions.push(`created_at <= $${paramIndex}`);
    params.push(endDate);
    paramIndex++;
  }

  if (status === 'active') {
    conditions.push('is_active = true');
  } else if (status === 'inactive') {
    conditions.push('is_active = false');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(
    `SELECT id, email, nickname, created_at, last_login_at, is_active
     FROM users
     ${whereClause}
     ORDER BY created_at DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else {
    // CSV格式
    const { exportUsersToCSV } = require('../utils/export');
    const filePath = await exportUsersToCSV(result.rows);
    res.download(filePath);
  }
};

// 导出方法数据
export const exportMethods = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', category, status } = req.query;

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (category) {
    conditions.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  if (status && status !== 'all') {
    conditions.push(`status = $${paramIndex}`);
    params.push(status);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(
    `SELECT id, title, category, difficulty, duration_minutes, status, view_count, select_count, created_at
     FROM methods
     ${whereClause}
     ORDER BY created_at DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else {
    // CSV格式
    const { exportMethodsToCSV } = require('../utils/export');
    const filePath = await exportMethodsToCSV(result.rows);
    res.download(filePath);
  }
};

// 导出练习记录
export const exportPractices = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', startDate, endDate, userId } = req.query;

  if (!startDate || !endDate) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Start date and end date are required');
  }

  const conditions: string[] = ['practice_date >= $1', 'practice_date <= $2'];
  const params: any[] = [startDate, endDate];
  let paramIndex = 3;

  if (userId) {
    conditions.push(`pr.user_id = $${paramIndex}`);
    params.push(userId);
    paramIndex++;
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  const result = await pool.query(
    `SELECT pr.id, u.email as user_email, m.title as method_title,
            pr.practice_date, pr.duration_minutes, pr.mood_before, pr.mood_after, pr.notes
     FROM practice_records pr
     JOIN users u ON pr.user_id = u.id
     JOIN methods m ON pr.method_id = m.id
     ${whereClause}
     ORDER BY pr.practice_date DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else if (format === 'excel') {
    // Excel格式
    const { exportPracticesToExcel } = require('../utils/export');
    const filePath = await exportPracticesToExcel(result.rows);
    res.download(filePath);
  } else {
    // CSV格式
    const { exportPracticesToExcel } = require('../utils/export');
    const filePath = await exportPracticesToExcel(result.rows);
    res.download(filePath);
  }
};

// ============= 用户管理 =============

// 获取用户列表
export const getUsers = async (req: AuthRequest, res: Response) => {
  const {
    search,
    status,
    page = 1,
    pageSize = 20,
    sortBy = 'created_at',
    sortOrder = 'desc',
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (search) {
    conditions.push(`(email ILIKE $${paramIndex} OR nickname ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }

  if (status === 'active') {
    conditions.push('u.is_active = true');
  } else if (status === 'inactive') {
    conditions.push('u.is_active = false');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const orderClause = `ORDER BY u.${sortBy} ${sortOrder.toUpperCase()}`;

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM users u ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT u.id, u.email, u.nickname, u.avatar_url, u.created_at, u.last_login_at, u.is_active,
            COUNT(DISTINCT um.id) as method_count,
            COUNT(DISTINCT pr.id) as practice_count
     FROM users u
     LEFT JOIN user_methods um ON u.id = um.user_id
     LEFT JOIN practice_records pr ON u.id = pr.user_id
     ${whereClause}
     GROUP BY u.id
     ${orderClause}
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

// 获取用户详情
export const getUserDetail = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const result = await pool.query(
    `SELECT u.id, u.email, u.nickname, u.avatar_url, u.created_at, u.last_login_at, u.is_active,
            COUNT(DISTINCT um.id) as method_count,
            COUNT(DISTINCT pr.id) as practice_count,
            COALESCE(SUM(pr.duration_minutes), 0) as total_practice_duration,
            COALESCE(AVG(pr.mood_after - pr.mood_before), 0) as avg_mood_improvement
     FROM users u
     LEFT JOIN user_methods um ON u.id = um.user_id
     LEFT JOIN practice_records pr ON u.id = pr.user_id
     WHERE u.id = $1
     GROUP BY u.id`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User not found');
  }

  res.json({
    success: true,
    data: result.rows[0],
  });
};

// 更新用户状态
export const updateUserStatus = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { is_active } = req.body;

  if (is_active === undefined) {
    throw new AppError(400, 'VALIDATION_ERROR', 'is_active is required');
  }

  await pool.query(
    'UPDATE users SET is_active = $1 WHERE id = $2',
    [is_active, id]
  );

  res.json({
    success: true,
    message: 'User status updated successfully',
  });
};

// 获取用户的方法库
export const getUserMethods = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const result = await pool.query(
    `SELECT um.*, m.title as method_name, m.category, m.difficulty,
            COUNT(pr.id) as practice_count
     FROM user_methods um
     JOIN methods m ON um.method_id = m.id
     LEFT JOIN practice_records pr ON um.user_id = pr.user_id AND um.method_id = pr.method_id
     WHERE um.user_id = $1
     GROUP BY um.id, m.title, m.category, m.difficulty
     ORDER BY um.selected_at DESC`,
    [id]
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

// 获取用户的练习记录
export const getUserPractices = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const {
    page = 1,
    pageSize = 20,
    startDate,
    endDate,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = ['pr.user_id = $1'];
  const params: any[] = [id];
  let paramIndex = 2;

  if (startDate) {
    conditions.push(`pr.practice_date >= $${paramIndex}`);
    params.push(startDate);
    paramIndex++;
  }

  if (endDate) {
    conditions.push(`pr.practice_date <= $${paramIndex}`);
    params.push(endDate);
    paramIndex++;
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM practice_records pr ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT pr.*, m.title as method_name
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     ${whereClause}
     ORDER BY pr.practice_date DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

// ============= 文件上传和媒体管理 =============

// 上传文件
export const uploadFile = async (req: AuthRequest, res: Response) => {
  const adminId = req.admin?.id;
  const file = req.file;

  if (!adminId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!file) {
    throw new AppError(400, 'VALIDATION_ERROR', 'No file uploaded');
  }

  // 获取文件类型
  let fileType: string;
  if (file.mimetype.startsWith('image/')) {
    fileType = 'image';
  } else if (file.mimetype.startsWith('audio/')) {
    fileType = 'audio';
  } else if (file.mimetype.startsWith('video/')) {
    fileType = 'video';
  } else {
    throw new AppError(400, 'INVALID_FILE_TYPE', 'Invalid file type');
  }

  // 生成URL
  const url = `/uploads/${file.filename}`;

  // 保存到数据库
  const result = await pool.query(
    `INSERT INTO media_files 
     (filename, original_name, file_type, mime_type, file_size, file_path, url, uploaded_by)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING *`,
    [file.filename, file.originalname, fileType, file.mimetype, file.size, file.path, url, adminId]
  );

  res.status(201).json({
    success: true,
    message: 'File uploaded successfully',
    data: result.rows[0],
  });
};

// 获取媒体文件列表
export const getMediaFiles = async (req: AuthRequest, res: Response) => {
  const {
    type,
    search,
    page = 1,
    pageSize = 20,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (type && type !== 'all') {
    conditions.push(`file_type = $${paramIndex}`);
    params.push(type);
    paramIndex++;
  }

  if (search) {
    conditions.push(`(filename ILIKE $${paramIndex} OR original_name ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM media_files ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT m.*, a.username as uploaded_by_name
     FROM media_files m
     LEFT JOIN admins a ON m.uploaded_by = a.id
     ${whereClause}
     ORDER BY m.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

// 删除媒体文件
export const deleteMediaFile = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  // 查询文件信息
  const fileResult = await pool.query(
    'SELECT * FROM media_files WHERE id = $1',
    [id]
  );

  if (fileResult.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Media file not found');
  }

  const file = fileResult.rows[0];

  // 删除数据库记录
  await pool.query('DELETE FROM media_files WHERE id = $1', [id]);

  // 删除物理文件
  const fs = require('fs');
  if (fs.existsSync(file.file_path)) {
    fs.unlinkSync(file.file_path);
  }

  res.json({
    success: true,
    message: 'Media file deleted successfully',
  });
};

// ============= 数据导出 =============

// 导出用户数据
export const exportUsers = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', startDate, endDate, status } = req.query;

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (startDate) {
    conditions.push(`created_at >= $${paramIndex}`);
    params.push(startDate);
    paramIndex++;
  }

  if (endDate) {
    conditions.push(`created_at <= $${paramIndex}`);
    params.push(endDate);
    paramIndex++;
  }

  if (status === 'active') {
    conditions.push('is_active = true');
  } else if (status === 'inactive') {
    conditions.push('is_active = false');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(
    `SELECT id, email, nickname, created_at, last_login_at, is_active
     FROM users
     ${whereClause}
     ORDER BY created_at DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else {
    // CSV格式
    const { exportUsersToCSV } = require('../utils/export');
    const filePath = await exportUsersToCSV(result.rows);
    res.download(filePath);
  }
};

// 导出方法数据
export const exportMethods = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', category, status } = req.query;

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (category) {
    conditions.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  if (status && status !== 'all') {
    conditions.push(`status = $${paramIndex}`);
    params.push(status);
    paramIndex++;
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(
    `SELECT id, title, category, difficulty, duration_minutes, status, view_count, select_count, created_at
     FROM methods
     ${whereClause}
     ORDER BY created_at DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else {
    // CSV格式
    const { exportMethodsToCSV } = require('../utils/export');
    const filePath = await exportMethodsToCSV(result.rows);
    res.download(filePath);
  }
};

// 导出练习记录
export const exportPractices = async (req: AuthRequest, res: Response) => {
  const { format = 'csv', startDate, endDate, userId } = req.query;

  if (!startDate || !endDate) {
    throw new AppError(400, 'VALIDATION_ERROR', 'Start date and end date are required');
  }

  const conditions: string[] = ['practice_date >= $1', 'practice_date <= $2'];
  const params: any[] = [startDate, endDate];
  let paramIndex = 3;

  if (userId) {
    conditions.push(`pr.user_id = $${paramIndex}`);
    params.push(userId);
    paramIndex++;
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  const result = await pool.query(
    `SELECT pr.id, u.email as user_email, m.title as method_title,
            pr.practice_date, pr.duration_minutes, pr.mood_before, pr.mood_after, pr.notes
     FROM practice_records pr
     JOIN users u ON pr.user_id = u.id
     JOIN methods m ON pr.method_id = m.id
     ${whereClause}
     ORDER BY pr.practice_date DESC`,
    params
  );

  if (format === 'json') {
    res.json({
      success: true,
      data: result.rows,
    });
  } else if (format === 'excel') {
    // Excel格式
    const { exportPracticesToExcel } = require('../utils/export');
    const filePath = await exportPracticesToExcel(result.rows);
    res.download(filePath);
  } else {
    // CSV格式
    const { exportPracticesToExcel } = require('../utils/export');
    const filePath = await exportPracticesToExcel(result.rows);
    res.download(filePath);
  }
};

// ============= 用户管理 =============

// 获取用户列表
export const getUsers = async (req: AuthRequest, res: Response) => {
  const {
    search,
    status,
    page = 1,
    pageSize = 20,
    sortBy = 'created_at',
    sortOrder = 'desc',
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (search) {
    conditions.push(`(email ILIKE $${paramIndex} OR nickname ILIKE $${paramIndex})`);
    params.push(`%${search}%`);
    paramIndex++;
  }

  if (status === 'active') {
    conditions.push('u.is_active = true');
  } else if (status === 'inactive') {
    conditions.push('u.is_active = false');
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const orderClause = `ORDER BY u.${sortBy} ${sortOrder.toUpperCase()}`;

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM users u ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT u.id, u.email, u.nickname, u.avatar_url, u.created_at, u.last_login_at, u.is_active,
            COUNT(DISTINCT um.id) as method_count,
            COUNT(DISTINCT pr.id) as practice_count
     FROM users u
     LEFT JOIN user_methods um ON u.id = um.user_id
     LEFT JOIN practice_records pr ON u.id = pr.user_id
     ${whereClause}
     GROUP BY u.id
     ${orderClause}
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

// 获取用户详情
export const getUserDetail = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const result = await pool.query(
    `SELECT u.id, u.email, u.nickname, u.avatar_url, u.created_at, u.last_login_at, u.is_active,
            COUNT(DISTINCT um.id) as method_count,
            COUNT(DISTINCT pr.id) as practice_count,
            COALESCE(SUM(pr.duration_minutes), 0) as total_practice_duration,
            COALESCE(AVG(pr.mood_after - pr.mood_before), 0) as avg_mood_improvement
     FROM users u
     LEFT JOIN user_methods um ON u.id = um.user_id
     LEFT JOIN practice_records pr ON u.id = pr.user_id
     WHERE u.id = $1
     GROUP BY u.id`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User not found');
  }

  res.json({
    success: true,
    data: result.rows[0],
  });
};

// 更新用户状态
export const updateUserStatus = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { is_active } = req.body;

  if (is_active === undefined) {
    throw new AppError(400, 'VALIDATION_ERROR', 'is_active is required');
  }

  await pool.query(
    'UPDATE users SET is_active = $1 WHERE id = $2',
    [is_active, id]
  );

  res.json({
    success: true,
    message: 'User status updated successfully',
  });
};

// 获取用户的方法库
export const getUserMethods = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const result = await pool.query(
    `SELECT um.*, m.title as method_name, m.category, m.difficulty,
            COUNT(pr.id) as practice_count
     FROM user_methods um
     JOIN methods m ON um.method_id = m.id
     LEFT JOIN practice_records pr ON um.user_id = pr.user_id AND um.method_id = pr.method_id
     WHERE um.user_id = $1
     GROUP BY um.id, m.title, m.category, m.difficulty
     ORDER BY um.selected_at DESC`,
    [id]
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

// 获取用户的练习记录
export const getUserPractices = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const {
    page = 1,
    pageSize = 20,
    startDate,
    endDate,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = ['pr.user_id = $1'];
  const params: any[] = [id];
  let paramIndex = 2;

  if (startDate) {
    conditions.push(`pr.practice_date >= $${paramIndex}`);
    params.push(startDate);
    paramIndex++;
  }

  if (endDate) {
    conditions.push(`pr.practice_date <= $${paramIndex}`);
    params.push(endDate);
    paramIndex++;
  }

  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM practice_records pr ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query(
    `SELECT pr.*, m.title as method_name
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     ${whereClause}
     ORDER BY pr.practice_date DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  res.json({
    success: true,
    data: {
      items: result.rows,
      total,
      page: Number(page),
      pageSize: Number(pageSize),
      totalPages: Math.ceil(total / Number(pageSize)),
    },
  });
};

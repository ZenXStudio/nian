import { Request, Response } from 'express';
import { pool } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { Method, AuthRequest, PaginatedResponse } from '../types';

// 获取方法列表
export const getMethods = async (req: Request, res: Response) => {
  const {
    category,
    difficulty,
    keyword,
    page = 1,
    pageSize = 20,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  // 构建查询条件
  const conditions: string[] = ["status = 'published'"];
  const params: any[] = [];
  let paramIndex = 1;

  if (category) {
    conditions.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  if (difficulty) {
    conditions.push(`difficulty = $${paramIndex}`);
    params.push(difficulty);
    paramIndex++;
  }

  if (keyword) {
    conditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
    params.push(`%${keyword}%`);
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
    `SELECT id, title, description, category, difficulty, duration_minutes, 
            cover_image_url, view_count, select_count, published_at
     FROM methods 
     ${whereClause}
     ORDER BY published_at DESC
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

// 获取方法详情
export const getMethodById = async (req: Request, res: Response) => {
  const { id } = req.params;

  const result = await pool.query<Method>(
    `SELECT * FROM methods WHERE id = $1 AND status = 'published'`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found');
  }

  // 增加浏览次数
  await pool.query(
    'UPDATE methods SET view_count = view_count + 1 WHERE id = $1',
    [id]
  );

  res.json({
    success: true,
    data: result.rows[0],
  });
};

// 获取推荐方法
export const getRecommendedMethods = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const limit = Number(req.query.limit) || 5;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  // 简单的推荐算法：基于用户已选方法的分类推荐相似方法
  const result = await pool.query<Method>(
    `SELECT DISTINCT m.id, m.title, m.description, m.category, m.difficulty, 
            m.duration_minutes, m.cover_image_url, m.select_count
     FROM methods m
     WHERE m.status = 'published'
       AND m.id NOT IN (
         SELECT method_id FROM user_methods WHERE user_id = $1
       )
       AND (
         m.category IN (
           SELECT DISTINCT me.category 
           FROM user_methods um 
           JOIN methods me ON um.method_id = me.id 
           WHERE um.user_id = $1
         )
         OR m.select_count > 10
       )
     ORDER BY m.select_count DESC, m.published_at DESC
     LIMIT $2`,
    [userId, limit]
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

// 获取方法分类列表
export const getCategories = async (req: Request, res: Response) => {
  const result = await pool.query(
    `SELECT DISTINCT category, COUNT(*) as count
     FROM methods
     WHERE status = 'published'
     GROUP BY category
     ORDER BY count DESC`
  );

  res.json({
    success: true,
    data: result.rows,
  });
};
import { Request, Response } from 'express';
import { pool } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { Method, AuthRequest, PaginatedResponse } from '../types';

// 获取方法列表
export const getMethods = async (req: Request, res: Response) => {
  const {
    category,
    difficulty,
    keyword,
    page = 1,
    pageSize = 20,
  } = req.query;

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  // 构建查询条件
  const conditions: string[] = ["status = 'published'"];
  const params: any[] = [];
  let paramIndex = 1;

  if (category) {
    conditions.push(`category = $${paramIndex}`);
    params.push(category);
    paramIndex++;
  }

  if (difficulty) {
    conditions.push(`difficulty = $${paramIndex}`);
    params.push(difficulty);
    paramIndex++;
  }

  if (keyword) {
    conditions.push(`(title ILIKE $${paramIndex} OR description ILIKE $${paramIndex})`);
    params.push(`%${keyword}%`);
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
    `SELECT id, title, description, category, difficulty, duration_minutes, 
            cover_image_url, view_count, select_count, published_at
     FROM methods 
     ${whereClause}
     ORDER BY published_at DESC
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

// 获取方法详情
export const getMethodById = async (req: Request, res: Response) => {
  const { id } = req.params;

  const result = await pool.query<Method>(
    `SELECT * FROM methods WHERE id = $1 AND status = 'published'`,
    [id]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found');
  }

  // 增加浏览次数
  await pool.query(
    'UPDATE methods SET view_count = view_count + 1 WHERE id = $1',
    [id]
  );

  res.json({
    success: true,
    data: result.rows[0],
  });
};

// 获取推荐方法
export const getRecommendedMethods = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const limit = Number(req.query.limit) || 5;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  // 简单的推荐算法：基于用户已选方法的分类推荐相似方法
  const result = await pool.query<Method>(
    `SELECT DISTINCT m.id, m.title, m.description, m.category, m.difficulty, 
            m.duration_minutes, m.cover_image_url, m.select_count
     FROM methods m
     WHERE m.status = 'published'
       AND m.id NOT IN (
         SELECT method_id FROM user_methods WHERE user_id = $1
       )
       AND (
         m.category IN (
           SELECT DISTINCT me.category 
           FROM user_methods um 
           JOIN methods me ON um.method_id = me.id 
           WHERE um.user_id = $1
         )
         OR m.select_count > 10
       )
     ORDER BY m.select_count DESC, m.published_at DESC
     LIMIT $2`,
    [userId, limit]
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

// 获取方法分类列表
export const getCategories = async (req: Request, res: Response) => {
  const result = await pool.query(
    `SELECT DISTINCT category, COUNT(*) as count
     FROM methods
     WHERE status = 'published'
     GROUP BY category
     ORDER BY count DESC`
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

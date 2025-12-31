import { Response } from 'express';
import { pool } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { AuthRequest, UserMethod } from '../types';

// 添加方法到个人库
export const addUserMethod = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const { method_id, target_count = 0 } = req.body;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!method_id) {
    throw new AppError(400, 'VALIDATION_ERROR', 'method_id is required');
  }

  // 检查方法是否存在
  const methodCheck = await pool.query(
    "SELECT id FROM methods WHERE id = $1 AND status = 'published'",
    [method_id]
  );

  if (methodCheck.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'Method not found');
  }

  // 检查是否已添加
  const existCheck = await pool.query(
    'SELECT id FROM user_methods WHERE user_id = $1 AND method_id = $2',
    [userId, method_id]
  );

  if (existCheck.rows.length > 0) {
    throw new AppError(409, 'DUPLICATE_ENTRY', 'Method already in your library');
  }

  // 添加到个人库
  await pool.query(
    `INSERT INTO user_methods (user_id, method_id, target_count) 
     VALUES ($1, $2, $3)`,
    [userId, method_id, target_count]
  );

  // 更新方法的选择次数
  await pool.query(
    'UPDATE methods SET select_count = select_count + 1 WHERE id = $1',
    [method_id]
  );

  res.status(201).json({
    success: true,
    message: 'Method added to your library',
  });
};

// 获取个人方法列表
export const getUserMethods = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const result = await pool.query(
    `SELECT um.*, m.title, m.description, m.category, m.difficulty, 
            m.duration_minutes, m.cover_image_url
     FROM user_methods um
     JOIN methods m ON um.method_id = m.id
     WHERE um.user_id = $1
     ORDER BY um.selected_at DESC`,
    [userId]
  );

  res.json({
    success: true,
    data: result.rows,
  });
};

// 更新个人方法
export const updateUserMethod = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const { id } = req.params;
  const { target_count, is_favorite } = req.body;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const updates: string[] = [];
  const params: any[] = [];
  let paramIndex = 1;

  if (target_count !== undefined) {
    updates.push(`target_count = $${paramIndex}`);
    params.push(target_count);
    paramIndex++;
  }

  if (is_favorite !== undefined) {
    updates.push(`is_favorite = $${paramIndex}`);
    params.push(is_favorite);
    paramIndex++;
  }

  if (updates.length === 0) {
    throw new AppError(400, 'VALIDATION_ERROR', 'No fields to update');
  }

  params.push(id, userId);

  const result = await pool.query(
    `UPDATE user_methods 
     SET ${updates.join(', ')}
     WHERE id = $${paramIndex} AND user_id = $${paramIndex + 1}
     RETURNING *`,
    params
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User method not found');
  }

  res.json({
    success: true,
    message: 'User method updated',
    data: result.rows[0],
  });
};

// 删除个人方法
export const deleteUserMethod = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const { id } = req.params;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const result = await pool.query(
    'DELETE FROM user_methods WHERE id = $1 AND user_id = $2 RETURNING method_id',
    [id, userId]
  );

  if (result.rows.length === 0) {
    throw new AppError(404, 'NOT_FOUND', 'User method not found');
  }

  // 减少方法的选择次数
  await pool.query(
    'UPDATE methods SET select_count = GREATEST(select_count - 1, 0) WHERE id = $1',
    [result.rows[0].method_id]
  );

  res.json({
    success: true,
    message: 'Method removed from your library',
  });
};

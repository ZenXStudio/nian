import { Response } from 'express';
import { pool } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { AuthRequest, PracticeRecord, PaginatedResponse } from '../types';

// 记录一次练习
export const createPracticeRecord = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const {
    method_id,
    duration_minutes,
    mood_before,
    mood_after,
    notes,
    questionnaire_result,
  } = req.body;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!method_id || !duration_minutes) {
    throw new AppError(400, 'VALIDATION_ERROR', 'method_id and duration_minutes are required');
  }

  // 验证心理状态评分范围
  if (mood_before && (mood_before < 1 || mood_before > 10)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'mood_before must be between 1 and 10');
  }
  if (mood_after && (mood_after < 1 || mood_after > 10)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'mood_after must be between 1 and 10');
  }

  // 开始事务
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 插入练习记录
    const recordResult = await client.query(
      `INSERT INTO practice_records 
       (user_id, method_id, practice_date, duration_minutes, mood_before, mood_after, notes, questionnaire_result)
       VALUES ($1, $2, CURRENT_DATE, $3, $4, $5, $6, $7)
       RETURNING *`,
      [userId, method_id, duration_minutes, mood_before || null, mood_after || null, notes || null, questionnaire_result || null]
    );

    // 更新user_methods表
    await client.query(
      `INSERT INTO user_methods (user_id, method_id, completed_count, total_duration_minutes, last_practice_at)
       VALUES ($1, $2, 1, $3, NOW())
       ON CONFLICT (user_id, method_id) 
       DO UPDATE SET 
         completed_count = user_methods.completed_count + 1,
         total_duration_minutes = user_methods.total_duration_minutes + $3,
         last_practice_at = NOW()`,
      [userId, method_id, duration_minutes]
    );

    // 更新连续打卡天数
    const yesterday = await client.query(
      `SELECT id FROM practice_records 
       WHERE user_id = $1 AND method_id = $2 
       AND practice_date = CURRENT_DATE - INTERVAL '1 day'`,
      [userId, method_id]
    );

    if (yesterday.rows.length > 0) {
      // 有昨天的记录，增加连续天数
      await client.query(
        `UPDATE user_methods 
         SET continuous_days = continuous_days + 1
         WHERE user_id = $1 AND method_id = $2`,
        [userId, method_id]
      );
    } else {
      // 没有昨天的记录，重置为1
      await client.query(
        `UPDATE user_methods 
         SET continuous_days = 1
         WHERE user_id = $1 AND method_id = $2`,
        [userId, method_id]
      );
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Practice recorded successfully',
      data: recordResult.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

// 获取练习历史
export const getPracticeHistory = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const {
    method_id,
    start_date,
    end_date,
    page = 1,
    pageSize = 20,
  } = req.query;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = ['user_id = $1'];
  const params: any[] = [userId];
  let paramIndex = 2;

  if (method_id) {
    conditions.push(`method_id = $${paramIndex}`);
    params.push(method_id);
    paramIndex++;
  }

  if (start_date) {
    conditions.push(`practice_date >= $${paramIndex}`);
    params.push(start_date);
    paramIndex++;
  }

  if (end_date) {
    conditions.push(`practice_date <= $${paramIndex}`);
    params.push(end_date);
    paramIndex++;
  }

  const whereClause = conditions.join(' AND ');

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM practice_records WHERE ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query<PracticeRecord>(
    `SELECT pr.*, m.title as method_title
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     WHERE ${whereClause}
     ORDER BY pr.practice_date DESC, pr.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  const response: PaginatedResponse<PracticeRecord> = {
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

// 获取练习统计
export const getPracticeStatistics = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const period = req.query.period || 'month';

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  let dateFilter = '';
  switch (period) {
    case 'week':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '7 days'";
      break;
    case 'month':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '30 days'";
      break;
    case 'year':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '365 days'";
      break;
  }

  // 总体统计
  const totalStats = await pool.query(
    `SELECT 
       COUNT(*) as total_practices,
       COALESCE(SUM(duration_minutes), 0) as total_duration,
       COUNT(DISTINCT practice_date) as practice_days,
       COALESCE(AVG(mood_after - mood_before), 0) as avg_mood_improvement
     FROM practice_records
     WHERE user_id = $1 ${dateFilter}`,
    [userId]
  );

  // 心理状态趋势
  const moodTrend = await pool.query(
    `SELECT 
       practice_date,
       AVG(mood_before) as avg_mood_before,
       AVG(mood_after) as avg_mood_after
     FROM practice_records
     WHERE user_id = $1 ${dateFilter}
       AND mood_before IS NOT NULL 
       AND mood_after IS NOT NULL
     GROUP BY practice_date
     ORDER BY practice_date`,
    [userId]
  );

  // 方法练习分布
  const methodDistribution = await pool.query(
    `SELECT 
       m.id,
       m.title,
       m.category,
       COUNT(*) as practice_count,
       SUM(pr.duration_minutes) as total_duration
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     WHERE pr.user_id = $1 ${dateFilter}
     GROUP BY m.id, m.title, m.category
     ORDER BY practice_count DESC
     LIMIT 10`,
    [userId]
  );

  // 连续打卡天数（最长）
  const maxContinuous = await pool.query(
    `SELECT MAX(continuous_days) as max_continuous_days
     FROM user_methods
     WHERE user_id = $1`,
    [userId]
  );

  res.json({
    success: true,
    data: {
      total_practices: parseInt(totalStats.rows[0].total_practices),
      total_duration: parseInt(totalStats.rows[0].total_duration),
      practice_days: parseInt(totalStats.rows[0].practice_days),
      avg_mood_improvement: parseFloat(totalStats.rows[0].avg_mood_improvement).toFixed(2),
      max_continuous_days: maxContinuous.rows[0].max_continuous_days || 0,
      mood_trend: moodTrend.rows,
      method_distribution: methodDistribution.rows,
    },
  });
};
import { Response } from 'express';
import { pool } from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { AuthRequest, PracticeRecord, PaginatedResponse } from '../types';

// 记录一次练习
export const createPracticeRecord = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const {
    method_id,
    duration_minutes,
    mood_before,
    mood_after,
    notes,
    questionnaire_result,
  } = req.body;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  if (!method_id || !duration_minutes) {
    throw new AppError(400, 'VALIDATION_ERROR', 'method_id and duration_minutes are required');
  }

  // 验证心理状态评分范围
  if (mood_before && (mood_before < 1 || mood_before > 10)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'mood_before must be between 1 and 10');
  }
  if (mood_after && (mood_after < 1 || mood_after > 10)) {
    throw new AppError(400, 'VALIDATION_ERROR', 'mood_after must be between 1 and 10');
  }

  // 开始事务
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 插入练习记录
    const recordResult = await client.query(
      `INSERT INTO practice_records 
       (user_id, method_id, practice_date, duration_minutes, mood_before, mood_after, notes, questionnaire_result)
       VALUES ($1, $2, CURRENT_DATE, $3, $4, $5, $6, $7)
       RETURNING *`,
      [userId, method_id, duration_minutes, mood_before || null, mood_after || null, notes || null, questionnaire_result || null]
    );

    // 更新user_methods表
    await client.query(
      `INSERT INTO user_methods (user_id, method_id, completed_count, total_duration_minutes, last_practice_at)
       VALUES ($1, $2, 1, $3, NOW())
       ON CONFLICT (user_id, method_id) 
       DO UPDATE SET 
         completed_count = user_methods.completed_count + 1,
         total_duration_minutes = user_methods.total_duration_minutes + $3,
         last_practice_at = NOW()`,
      [userId, method_id, duration_minutes]
    );

    // 更新连续打卡天数
    const yesterday = await client.query(
      `SELECT id FROM practice_records 
       WHERE user_id = $1 AND method_id = $2 
       AND practice_date = CURRENT_DATE - INTERVAL '1 day'`,
      [userId, method_id]
    );

    if (yesterday.rows.length > 0) {
      // 有昨天的记录，增加连续天数
      await client.query(
        `UPDATE user_methods 
         SET continuous_days = continuous_days + 1
         WHERE user_id = $1 AND method_id = $2`,
        [userId, method_id]
      );
    } else {
      // 没有昨天的记录，重置为1
      await client.query(
        `UPDATE user_methods 
         SET continuous_days = 1
         WHERE user_id = $1 AND method_id = $2`,
        [userId, method_id]
      );
    }

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Practice recorded successfully',
      data: recordResult.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

// 获取练习历史
export const getPracticeHistory = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const {
    method_id,
    start_date,
    end_date,
    page = 1,
    pageSize = 20,
  } = req.query;

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  const offset = (Number(page) - 1) * Number(pageSize);
  const limit = Number(pageSize);

  const conditions: string[] = ['user_id = $1'];
  const params: any[] = [userId];
  let paramIndex = 2;

  if (method_id) {
    conditions.push(`method_id = $${paramIndex}`);
    params.push(method_id);
    paramIndex++;
  }

  if (start_date) {
    conditions.push(`practice_date >= $${paramIndex}`);
    params.push(start_date);
    paramIndex++;
  }

  if (end_date) {
    conditions.push(`practice_date <= $${paramIndex}`);
    params.push(end_date);
    paramIndex++;
  }

  const whereClause = conditions.join(' AND ');

  // 查询总数
  const countResult = await pool.query(
    `SELECT COUNT(*) FROM practice_records WHERE ${whereClause}`,
    params
  );
  const total = parseInt(countResult.rows[0].count);

  // 查询数据
  const result = await pool.query<PracticeRecord>(
    `SELECT pr.*, m.title as method_title
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     WHERE ${whereClause}
     ORDER BY pr.practice_date DESC, pr.created_at DESC
     LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
    [...params, limit, offset]
  );

  const response: PaginatedResponse<PracticeRecord> = {
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

// 获取练习统计
export const getPracticeStatistics = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  const period = req.query.period || 'month';

  if (!userId) {
    throw new AppError(401, 'AUTH_FAILED', 'Not authenticated');
  }

  let dateFilter = '';
  switch (period) {
    case 'week':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '7 days'";
      break;
    case 'month':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '30 days'";
      break;
    case 'year':
      dateFilter = "AND practice_date >= CURRENT_DATE - INTERVAL '365 days'";
      break;
  }

  // 总体统计
  const totalStats = await pool.query(
    `SELECT 
       COUNT(*) as total_practices,
       COALESCE(SUM(duration_minutes), 0) as total_duration,
       COUNT(DISTINCT practice_date) as practice_days,
       COALESCE(AVG(mood_after - mood_before), 0) as avg_mood_improvement
     FROM practice_records
     WHERE user_id = $1 ${dateFilter}`,
    [userId]
  );

  // 心理状态趋势
  const moodTrend = await pool.query(
    `SELECT 
       practice_date,
       AVG(mood_before) as avg_mood_before,
       AVG(mood_after) as avg_mood_after
     FROM practice_records
     WHERE user_id = $1 ${dateFilter}
       AND mood_before IS NOT NULL 
       AND mood_after IS NOT NULL
     GROUP BY practice_date
     ORDER BY practice_date`,
    [userId]
  );

  // 方法练习分布
  const methodDistribution = await pool.query(
    `SELECT 
       m.id,
       m.title,
       m.category,
       COUNT(*) as practice_count,
       SUM(pr.duration_minutes) as total_duration
     FROM practice_records pr
     JOIN methods m ON pr.method_id = m.id
     WHERE pr.user_id = $1 ${dateFilter}
     GROUP BY m.id, m.title, m.category
     ORDER BY practice_count DESC
     LIMIT 10`,
    [userId]
  );

  // 连续打卡天数（最长）
  const maxContinuous = await pool.query(
    `SELECT MAX(continuous_days) as max_continuous_days
     FROM user_methods
     WHERE user_id = $1`,
    [userId]
  );

  res.json({
    success: true,
    data: {
      total_practices: parseInt(totalStats.rows[0].total_practices),
      total_duration: parseInt(totalStats.rows[0].total_duration),
      practice_days: parseInt(totalStats.rows[0].practice_days),
      avg_mood_improvement: parseFloat(totalStats.rows[0].avg_mood_improvement).toFixed(2),
      max_continuous_days: maxContinuous.rows[0].max_continuous_days || 0,
      mood_trend: moodTrend.rows,
      method_distribution: methodDistribution.rows,
    },
  });
};

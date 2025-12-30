import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AuthRequest } from '../types';
import { AppError } from './errorHandler';

const JWT_SECRET = process.env.JWT_SECRET || 'default-secret-key';

// 用户认证中间件
export const authenticateUser = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(401, 'AUTH_FAILED', 'No token provided');
    }

    const token = authHeader.substring(7);
    
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as { id: number; email: string };
      req.user = decoded;
      next();
    } catch (error) {
      throw new AppError(401, 'TOKEN_EXPIRED', 'Invalid or expired token');
    }
  } catch (error) {
    next(error);
  }
};

// 管理员认证中间件
export const authenticateAdmin = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(401, 'AUTH_FAILED', 'No token provided');
    }

    const token = authHeader.substring(7);
    
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as { 
        id: number; 
        username: string; 
        role: string;
        isAdmin: boolean;
      };
      
      if (!decoded.isAdmin) {
        throw new AppError(403, 'PERMISSION_DENIED', 'Admin access required');
      }
      
      req.admin = {
        id: decoded.id,
        username: decoded.username,
        role: decoded.role,
      };
      next();
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(401, 'TOKEN_EXPIRED', 'Invalid or expired token');
    }
  } catch (error) {
    next(error);
  }
};

// 生成JWT token
export const generateToken = (payload: object, expiresIn?: string): string => {
  return jwt.sign(
    payload,
    JWT_SECRET,
    { expiresIn: expiresIn || process.env.JWT_EXPIRES_IN || '7d' }
  );
};

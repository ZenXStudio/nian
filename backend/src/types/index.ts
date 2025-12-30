import { Request } from 'express';

// 用户相关类型
export interface User {
  id: number;
  email: string;
  nickname?: string;
  avatar_url?: string;
  created_at: Date;
  last_login_at?: Date;
  is_active: boolean;
}

export interface UserWithPassword extends User {
  password_hash: string;
}

// 方法相关类型
export interface Method {
  id: number;
  title: string;
  description: string;
  category: string;
  difficulty: string;
  duration_minutes: number;
  cover_image_url?: string;
  content_json: any;
  status: 'draft' | 'pending' | 'published' | 'archived';
  view_count: number;
  select_count: number;
  created_by?: number;
  created_at: Date;
  updated_at: Date;
  published_at?: Date;
}

// 用户方法关联
export interface UserMethod {
  id: number;
  user_id: number;
  method_id: number;
  selected_at: Date;
  target_count: number;
  completed_count: number;
  total_duration_minutes: number;
  continuous_days: number;
  last_practice_at?: Date;
  is_favorite: boolean;
}

// 练习记录
export interface PracticeRecord {
  id: number;
  user_id: number;
  method_id: number;
  practice_date: Date;
  duration_minutes: number;
  mood_before?: number;
  mood_after?: number;
  notes?: string;
  questionnaire_result?: any;
  created_at: Date;
}

// 管理员
export interface Admin {
  id: number;
  username: string;
  role: 'super_admin' | 'content_admin' | 'analyst';
  email: string;
  is_active: boolean;
  created_at: Date;
  last_login_at?: Date;
}

export interface AdminWithPassword extends Admin {
  password_hash: string;
}

// 扩展Express Request类型
export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
  };
  admin?: {
    id: number;
    username: string;
    role: string;
  };
}

// API响应类型
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: {
    code: string;
    message: string;
  };
}

// 分页响应
export interface PaginatedResponse<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}
import { Request } from 'express';

// 用户相关类型
export interface User {
  id: number;
  email: string;
  nickname?: string;
  avatar_url?: string;
  created_at: Date;
  last_login_at?: Date;
  is_active: boolean;
}

export interface UserWithPassword extends User {
  password_hash: string;
}

// 方法相关类型
export interface Method {
  id: number;
  title: string;
  description: string;
  category: string;
  difficulty: string;
  duration_minutes: number;
  cover_image_url?: string;
  content_json: any;
  status: 'draft' | 'pending' | 'published' | 'archived';
  view_count: number;
  select_count: number;
  created_by?: number;
  created_at: Date;
  updated_at: Date;
  published_at?: Date;
}

// 用户方法关联
export interface UserMethod {
  id: number;
  user_id: number;
  method_id: number;
  selected_at: Date;
  target_count: number;
  completed_count: number;
  total_duration_minutes: number;
  continuous_days: number;
  last_practice_at?: Date;
  is_favorite: boolean;
}

// 练习记录
export interface PracticeRecord {
  id: number;
  user_id: number;
  method_id: number;
  practice_date: Date;
  duration_minutes: number;
  mood_before?: number;
  mood_after?: number;
  notes?: string;
  questionnaire_result?: any;
  created_at: Date;
}

// 管理员
export interface Admin {
  id: number;
  username: string;
  role: 'super_admin' | 'content_admin' | 'analyst';
  email: string;
  is_active: boolean;
  created_at: Date;
  last_login_at?: Date;
}

export interface AdminWithPassword extends Admin {
  password_hash: string;
}

// 扩展Express Request类型
export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
  };
  admin?: {
    id: number;
    username: string;
    role: string;
  };
}

// API响应类型
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: {
    code: string;
    message: string;
  };
}

// 分页响应
export interface PaginatedResponse<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}

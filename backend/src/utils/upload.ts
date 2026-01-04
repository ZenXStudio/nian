import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { Request } from 'express';
import { AppError } from '../middleware/errorHandler';

// 确保上传目录存在
const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// 创建年月目录
const getUploadPath = (): string => {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const uploadPath = path.join(uploadsDir, String(year), month);
  
  if (!fs.existsSync(uploadPath)) {
    fs.mkdirSync(uploadPath, { recursive: true });
  }
  
  return uploadPath;
};

// 文件类型验证
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  // 允许的文件类型
  const allowedImageTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
  const allowedAudioTypes = ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/m4a', 'audio/x-m4a'];
  const allowedVideoTypes = ['video/mp4', 'video/webm', 'video/quicktime'];
  
  const allAllowedTypes = [...allowedImageTypes, ...allowedAudioTypes, ...allowedVideoTypes];
  
  if (allAllowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new AppError(400, 'INVALID_FILE_TYPE', `不支持的文件类型: ${file.mimetype}`));
  }
};

// 文件大小限制（单位：字节）
const getFileSizeLimit = (mimetype: string): number => {
  if (mimetype.startsWith('image/')) {
    return 5 * 1024 * 1024; // 图片: 5MB
  } else if (mimetype.startsWith('audio/')) {
    return 20 * 1024 * 1024; // 音频: 20MB
  } else if (mimetype.startsWith('video/')) {
    return 100 * 1024 * 1024; // 视频: 100MB
  }
  return 5 * 1024 * 1024; // 默认: 5MB
};

// Multer 存储配置
const storage = multer.diskStorage({
  destination: (req: Request, file: Express.Multer.File, cb: (error: Error | null, destination: string) => void) => {
    try {
      const uploadPath = getUploadPath();
      cb(null, uploadPath);
    } catch (error) {
      cb(error as Error, '');
    }
  },
  filename: (req: Request, file: Express.Multer.File, cb: (error: Error | null, filename: string) => void) => {
    // 生成唯一文件名: timestamp-randomstring.ext
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `${uniqueSuffix}${ext}`);
  }
});

// 创建 multer 实例
export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 100 * 1024 * 1024 // 最大100MB
  }
});

// 获取文件类型
export const getFileType = (mimetype: string): 'image' | 'audio' | 'video' => {
  if (mimetype.startsWith('image/')) {
    return 'image';
  } else if (mimetype.startsWith('audio/')) {
    return 'audio';
  } else if (mimetype.startsWith('video/')) {
    return 'video';
  }
  throw new AppError(400, 'INVALID_FILE_TYPE', '无法识别的文件类型');
};

// 生成文件URL
export const generateFileUrl = (filePath: string): string => {
  // 从完整路径中提取相对路径
  const uploadsIndex = filePath.indexOf('uploads');
  if (uploadsIndex === -1) {
    throw new Error('Invalid file path');
  }
  
  const relativePath = filePath.substring(uploadsIndex);
  // 转换为URL路径（Windows路径转Unix路径）
  const urlPath = relativePath.replace(/\\/g, '/');
  return `/${urlPath}`;
};

// 删除文件
export const deleteFile = (filePath: string): void => {
  try {
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  } catch (error) {
    console.error('删除文件失败:', error);
  }
};

// 验证文件大小
export const validateFileSize = (file: Express.Multer.File): void => {
  const limit = getFileSizeLimit(file.mimetype);
  if (file.size > limit) {
    const limitMB = (limit / (1024 * 1024)).toFixed(0);
    throw new AppError(400, 'FILE_TOO_LARGE', `文件大小超过限制 (${limitMB}MB)`);
  }
};
};

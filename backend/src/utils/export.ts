import { createObjectCsvWriter } from 'csv-writer';
import ExcelJS from 'exceljs';
import path from 'path';
import fs from 'fs';

// 确保导出目录存在
const exportsDir = path.join(process.cwd(), 'exports');
if (!fs.existsSync(exportsDir)) {
  fs.mkdirSync(exportsDir, { recursive: true });
}

// 生成唯一文件名
const generateFileName = (prefix: string, extension: string): string => {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  return `${prefix}_${timestamp}.${extension}`;
};

// 导出用户数据为CSV
export const exportUsersToCSV = async (users: any[]): Promise<string> => {
  const fileName = generateFileName('users', 'csv');
  const filePath = path.join(exportsDir, fileName);

  const csvWriter = createObjectCsvWriter({
    path: filePath,
    header: [
      { id: 'id', title: 'ID' },
      { id: 'email', title: '邮箱' },
      { id: 'nickname', title: '昵称' },
      { id: 'created_at', title: '注册时间' },
      { id: 'last_login_at', title: '最后登录' },
      { id: 'is_active', title: '状态' }
    ]
  });

  await csvWriter.writeRecords(users);
  return filePath;
};

// 导出方法数据为CSV
export const exportMethodsToCSV = async (methods: any[]): Promise<string> => {
  const fileName = generateFileName('methods', 'csv');
  const filePath = path.join(exportsDir, fileName);

  const csvWriter = createObjectCsvWriter({
    path: filePath,
    header: [
      { id: 'id', title: 'ID' },
      { id: 'title', title: '标题' },
      { id: 'category', title: '分类' },
      { id: 'difficulty', title: '难度' },
      { id: 'duration_minutes', title: '时长(分钟)' },
      { id: 'status', title: '状态' },
      { id: 'view_count', title: '浏览次数' },
      { id: 'select_count', title: '选择次数' },
      { id: 'created_at', title: '创建时间' }
    ]
  });

  await csvWriter.writeRecords(methods);
  return filePath;
};

// 导出练习记录为Excel
export const exportPracticesToExcel = async (practices: any[]): Promise<string> => {
  const fileName = generateFileName('practices', 'xlsx');
  const filePath = path.join(exportsDir, fileName);

  const workbook = new ExcelJS.Workbook();
  const worksheet = workbook.addWorksheet('练习记录');

  // 设置列标题
  worksheet.columns = [
    { header: 'ID', key: 'id', width: 10 },
    { header: '用户邮箱', key: 'user_email', width: 25 },
    { header: '方法名称', key: 'method_title', width: 20 },
    { header: '练习日期', key: 'practice_date', width: 15 },
    { header: '时长(分钟)', key: 'duration_minutes', width: 12 },
    { header: '练习前心情', key: 'mood_before', width: 12 },
    { header: '练习后心情', key: 'mood_after', width: 12 },
    { header: '心情改善', key: 'mood_improvement', width: 12 },
    { header: '备注', key: 'notes', width: 30 }
  ];

  // 添加数据行
  practices.forEach(practice => {
    worksheet.addRow({
      ...practice,
      mood_improvement: practice.mood_after - practice.mood_before
    });
  });

  // 设置表头样式
  worksheet.getRow(1).font = { bold: true };
  worksheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFE0E0E0' }
  };

  // 保存文件
  await workbook.xlsx.writeFile(filePath);
  return filePath;
};

// 导出为JSON
export const exportToJSON = async (data: any[], prefix: string): Promise<string> => {
  const fileName = generateFileName(prefix, 'json');
  const filePath = path.join(exportsDir, fileName);

  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
  return filePath;
};

// 清理过期导出文件（超过24小时）
export const cleanupExpiredExports = (): void => {
  const files = fs.readdirSync(exportsDir);
  const now = Date.now();
  const maxAge = 24 * 60 * 60 * 1000; // 24小时

  files.forEach(file => {
    const filePath = path.join(exportsDir, file);
    const stat = fs.statSync(filePath);
    
    if (now - stat.mtimeMs > maxAge) {
      fs.unlinkSync(filePath);
      console.log(`已删除过期导出文件: ${file}`);
    }
  });
};

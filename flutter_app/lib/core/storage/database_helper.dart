import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

/// SQLite数据库帮助类
/// 
/// 管理应用的本地数据库，包括创建、升级和查询
@lazySingleton
class DatabaseHelper {
  static const String _databaseName = 'nian.db';
  static const int _databaseVersion = 1;
  
  Database? _database;
  
  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    AppLogger.info('初始化数据库: $path');
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }
  
  /// 配置数据库
  Future<void> _onConfigure(Database db) async {
    // 启用外键约束
    await db.execute('PRAGMA foreign_keys = ON');
  }
  
  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('创建数据库表，版本: $version');
    
    // 用户缓存表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // 方法缓存表
    await db.execute('''
      CREATE TABLE methods (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT NOT NULL,
        duration INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        audio_url TEXT,
        video_url TEXT,
        image_url TEXT,
        tags TEXT,
        view_count INTEGER DEFAULT 0,
        like_count INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        created_at_timestamp INTEGER NOT NULL
      )
    ''');
    
    // 创建索引以提高查询性能
    await db.execute('''
      CREATE INDEX idx_methods_category ON methods(category)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_methods_status ON methods(status)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_methods_created_at ON methods(created_at_timestamp DESC)
    ''');
    
    // 个人方法缓存表
    await db.execute('''
      CREATE TABLE user_methods (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        method_id INTEGER NOT NULL,
        notes TEXT,
        is_favorite INTEGER DEFAULT 0,
        practice_count INTEGER DEFAULT 0,
        last_practiced_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (method_id) REFERENCES methods(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_user_methods_user_id ON user_methods(user_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_user_methods_method_id ON user_methods(method_id)
    ''');
    
    // 练习记录缓存表
    await db.execute('''
      CREATE TABLE practice_records (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        method_id INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        mood_before INTEGER,
        mood_after INTEGER,
        notes TEXT,
        practiced_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        practiced_at_timestamp INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (method_id) REFERENCES methods(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_practice_records_user_id ON practice_records(user_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_practice_records_method_id ON practice_records(method_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_practice_records_practiced_at ON practice_records(practiced_at_timestamp DESC)
    ''');
    
    AppLogger.info('数据库表创建完成');
  }
  
  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info('升级数据库: $oldVersion -> $newVersion');
    
    // 根据版本号执行不同的升级逻辑
    if (oldVersion < 2) {
      // 版本2的升级逻辑
      // TODO: 添加升级脚本
    }
  }
  
  /// 清空所有表（谨慎使用）
  Future<void> clearAllTables() async {
    final db = await database;
    
    AppLogger.warning('清空所有数据库表');
    
    await db.delete('practice_records');
    await db.delete('user_methods');
    await db.delete('methods');
    await db.delete('users');
  }
  
  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.info('数据库已关闭');
    }
  }
  
  /// 获取数据库大小（字节）
  Future<int> getDatabaseSize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    try {
      final file = await databaseFactory.openDatabase(path);
      await file.close();
      // 实际实现需要使用File API获取文件大小
      return 0;
    } catch (e) {
      AppLogger.error('获取数据库大小失败', error: e);
      return 0;
    }
  }
}

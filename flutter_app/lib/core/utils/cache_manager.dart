import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 缓存管理器
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  
  factory CacheManager() => _instance;
  
  CacheManager._internal();

  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      // 获取临时目录缓存大小
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        totalSize += await _calculateDirectorySize(tempDir);
      }

      // 获取应用缓存目录大小
      final appCacheDir = await getApplicationCacheDirectory();
      if (await appCacheDir.exists()) {
        totalSize += await _calculateDirectorySize(appCacheDir);
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    try {
      // 清除网络图片缓存
      await DefaultCacheManager().emptyCache();

      // 清除临时目录
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectory(tempDir);
      }

      // 清除应用缓存目录
      final appCacheDir = await getApplicationCacheDirectory();
      if (await appCacheDir.exists()) {
        await _deleteDirectory(appCacheDir);
      }
    } catch (e) {
      throw Exception('清除缓存失败：${e.toString()}');
    }
  }

  /// 清除图片缓存
  Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      throw Exception('清除图片缓存失败：${e.toString()}');
    }
  }

  /// 获取格式化的缓存大小字符串
  String getFormattedCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 计算目录大小
  Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      // 忽略权限错误
    }
    return size;
  }

  /// 删除目录内容（保留目录本身）
  Future<void> _deleteDirectory(Directory directory) async {
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      // 忽略权限错误
    }
  }
}
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 缓存管理器
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  
  factory CacheManager() => _instance;
  
  CacheManager._internal();

  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      // 获取临时目录缓存大小
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        totalSize += await _calculateDirectorySize(tempDir);
      }

      // 获取应用缓存目录大小
      final appCacheDir = await getApplicationCacheDirectory();
      if (await appCacheDir.exists()) {
        totalSize += await _calculateDirectorySize(appCacheDir);
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    try {
      // 清除网络图片缓存
      await DefaultCacheManager().emptyCache();

      // 清除临时目录
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectory(tempDir);
      }

      // 清除应用缓存目录
      final appCacheDir = await getApplicationCacheDirectory();
      if (await appCacheDir.exists()) {
        await _deleteDirectory(appCacheDir);
      }
    } catch (e) {
      throw Exception('清除缓存失败：${e.toString()}');
    }
  }

  /// 清除图片缓存
  Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      throw Exception('清除图片缓存失败：${e.toString()}');
    }
  }

  /// 获取格式化的缓存大小字符串
  String getFormattedCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 计算目录大小
  Future<int> _calculateDirectorySize(Directory directory) async {
    int size = 0;
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      // 忽略权限错误
    }
    return size;
  }

  /// 删除目录内容（保留目录本身）
  Future<void> _deleteDirectory(Directory directory) async {
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: false, followLinks: false)) {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      // 忽略权限错误
    }
  }
}

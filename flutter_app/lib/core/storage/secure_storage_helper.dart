import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

/// 安全存储帮助类
/// 
/// 封装FlutterSecureStorage，用于存储敏感数据（如令牌、密码等）
@lazySingleton
class SecureStorageHelper {
  final FlutterSecureStorage _storage;
  
  SecureStorageHelper(this._storage);
  
  // ========== 存储键常量 ==========
  
  /// 认证令牌
  static const String keyAuthToken = 'auth_token';
  
  /// 刷新令牌
  static const String keyRefreshToken = 'refresh_token';
  
  /// 用户密码（用于记住密码功能）
  static const String keyUserPassword = 'user_password';
  
  /// 用户邮箱（用于记住用户名功能）
  static const String keyUserEmail = 'user_email';
  
  /// 生物识别启用状态
  static const String keyBiometricEnabled = 'biometric_enabled';
  
  // ========== 通用方法 ==========
  
  /// 写入数据
  Future<void> write({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('安全存储写入: $key');
    } catch (e) {
      AppLogger.error('安全存储写入失败', error: e);
      rethrow;
    }
  }
  
  /// 读取数据
  Future<String?> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      AppLogger.debug('安全存储读取: $key');
      return value;
    } catch (e) {
      AppLogger.error('安全存储读取失败', error: e);
      return null;
    }
  }
  
  /// 删除数据
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('安全存储删除: $key');
    } catch (e) {
      AppLogger.error('安全存储删除失败', error: e);
      rethrow;
    }
  }
  
  /// 检查键是否存在
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      AppLogger.error('安全存储检查键失败', error: e);
      return false;
    }
  }
  
  /// 清空所有数据
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.warning('清空所有安全存储数据');
    } catch (e) {
      AppLogger.error('清空安全存储失败', error: e);
      rethrow;
    }
  }
  
  /// 读取所有数据
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.error('读取所有安全存储数据失败', error: e);
      return {};
    }
  }
  
  // ========== 业务相关方法 ==========
  
  /// 保存认证令牌
  Future<void> saveAuthToken(String token) async {
    await write(key: keyAuthToken, value: token);
  }
  
  /// 获取认证令牌
  Future<String?> getAuthToken() async {
    return await read(key: keyAuthToken);
  }
  
  /// 删除认证令牌
  Future<void> deleteAuthToken() async {
    await delete(key: keyAuthToken);
  }
  
  /// 检查是否有认证令牌
  Future<bool> hasAuthToken() async {
    return await containsKey(key: keyAuthToken);
  }
  
  /// 保存刷新令牌
  Future<void> saveRefreshToken(String token) async {
    await write(key: keyRefreshToken, value: token);
  }
  
  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await read(key: keyRefreshToken);
  }
  
  /// 删除刷新令牌
  Future<void> deleteRefreshToken() async {
    await delete(key: keyRefreshToken);
  }
  
  /// 保存用户密码（记住密码功能）
  Future<void> saveUserPassword(String password) async {
    await write(key: keyUserPassword, value: password);
  }
  
  /// 获取用户密码
  Future<String?> getUserPassword() async {
    return await read(key: keyUserPassword);
  }
  
  /// 删除用户密码
  Future<void> deleteUserPassword() async {
    await delete(key: keyUserPassword);
  }
  
  /// 保存用户邮箱
  Future<void> saveUserEmail(String email) async {
    await write(key: keyUserEmail, value: email);
  }
  
  /// 获取用户邮箱
  Future<String?> getUserEmail() async {
    return await read(key: keyUserEmail);
  }
  
  /// 删除用户邮箱
  Future<void> deleteUserEmail() async {
    await delete(key: keyUserEmail);
  }
  
  /// 保存生物识别启用状态
  Future<void> saveBiometricEnabled(bool enabled) async {
    await write(key: keyBiometricEnabled, value: enabled.toString());
  }
  
  /// 获取生物识别启用状态
  Future<bool> getBiometricEnabled() async {
    final value = await read(key: keyBiometricEnabled);
    return value == 'true';
  }
  
  /// 清除所有认证数据
  Future<void> clearAuthData() async {
    await deleteAuthToken();
    await deleteRefreshToken();
  }
  
  /// 清除所有用户凭据
  Future<void> clearUserCredentials() async {
    await deleteUserPassword();
    await deleteUserEmail();
    await clearAuthData();
  }
}


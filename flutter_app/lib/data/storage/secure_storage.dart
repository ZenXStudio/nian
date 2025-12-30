import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mental_app/config/api_constants.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 保存 token
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  // 获取 token
  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  // 删除 token
  Future<void> deleteToken() async {
    await _storage.delete(key: ApiConstants.tokenKey);
  }

  // 保存用户信息
  Future<void> saveUser(String userJson) async {
    await _storage.write(key: ApiConstants.userKey, value: userJson);
  }

  // 获取用户信息
  Future<String?> getUser() async {
    return await _storage.read(key: ApiConstants.userKey);
  }

  // 删除用户信息
  Future<void> deleteUser() async {
    await _storage.delete(key: ApiConstants.userKey);
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

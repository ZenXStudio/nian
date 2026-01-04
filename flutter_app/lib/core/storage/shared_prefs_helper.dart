import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

/// SharedPreferences帮助类
/// 
/// 封装SharedPreferences，提供类型安全的键值对存储
@lazySingleton
class SharedPrefsHelper {
  final SharedPreferences _prefs;
  
  SharedPrefsHelper(this._prefs);
  
  // ========== 存储键常量 ==========
  
  /// 用户ID
  static const String keyUserId = 'user_id';
  
  /// 用户名
  static const String keyUsername = 'username';
  
  /// 用户角色
  static const String keyUserRole = 'user_role';
  
  /// 是否首次启动
  static const String keyIsFirstLaunch = 'is_first_launch';
  
  /// 主题模式 (light/dark/system)
  static const String keyThemeMode = 'theme_mode';
  
  /// 语言代码
  static const String keyLanguageCode = 'language_code';
  
  /// 是否启用通知
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  /// 上次同步时间
  static const String keyLastSyncTime = 'last_sync_time';
  
  /// 是否自动播放音频
  static const String keyAutoPlayAudio = 'auto_play_audio';
  
  /// 音频音量
  static const String keyAudioVolume = 'audio_volume';
  
  /// 是否仅在WiFi下加载媒体
  static const String keyWifiOnlyMedia = 'wifi_only_media';
  
  // ========== 通用方法 ==========
  
  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      AppLogger.debug('保存字符串: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('保存字符串失败', error: e);
      return false;
    }
  }
  
  /// 获取字符串
  String? getString(String key, {String? defaultValue}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      AppLogger.debug('保存整数: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('保存整数失败', error: e);
      return false;
    }
  }
  
  /// 获取整数
  int? getInt(String key, {int? defaultValue}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      AppLogger.debug('保存布尔值: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('保存布尔值失败', error: e);
      return false;
    }
  }
  
  /// 获取布尔值
  bool? getBool(String key, {bool? defaultValue}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _prefs.setDouble(key, value);
      AppLogger.debug('保存浮点数: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('保存浮点数失败', error: e);
      return false;
    }
  }
  
  /// 获取双精度浮点数
  double? getDouble(String key, {double? defaultValue}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      AppLogger.debug('保存字符串列表: $key = $value');
      return result;
    } catch (e) {
      AppLogger.error('保存字符串列表失败', error: e);
      return false;
    }
  }
  
  /// 获取字符串列表
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }
  
  /// 删除键
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      AppLogger.debug('删除键: $key');
      return result;
    } catch (e) {
      AppLogger.error('删除键失败', error: e);
      return false;
    }
  }
  
  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
  
  /// 清空所有数据
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      AppLogger.warning('清空所有SharedPreferences数据');
      return result;
    } catch (e) {
      AppLogger.error('清空数据失败', error: e);
      return false;
    }
  }
  
  /// 获取所有键
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
  
  // ========== 业务相关方法 ==========
  
  /// 保存用户ID
  Future<bool> saveUserId(int userId) {
    return setInt(keyUserId, userId);
  }
  
  /// 获取用户ID
  int? getUserId() {
    return getInt(keyUserId);
  }
  
  /// 保存用户名
  Future<bool> saveUsername(String username) {
    return setString(keyUsername, username);
  }
  
  /// 获取用户名
  String? getUsername() {
    return getString(keyUsername);
  }
  
  /// 保存用户角色
  Future<bool> saveUserRole(String role) {
    return setString(keyUserRole, role);
  }
  
  /// 获取用户角色
  String? getUserRole() {
    return getString(keyUserRole);
  }
  
  /// 检查是否首次启动
  bool isFirstLaunch() {
    return getBool(keyIsFirstLaunch) ?? true;
  }
  
  /// 标记已启动
  Future<bool> markLaunched() {
    return setBool(keyIsFirstLaunch, false);
  }
  
  /// 保存主题模式
  Future<bool> saveThemeMode(String mode) {
    return setString(keyThemeMode, mode);
  }
  
  /// 获取主题模式
  String getThemeMode() {
    return getString(keyThemeMode) ?? 'system';
  }
  
  /// 保存语言代码
  Future<bool> saveLanguageCode(String code) {
    return setString(keyLanguageCode, code);
  }
  
  /// 获取语言代码
  String? getLanguageCode() {
    return getString(keyLanguageCode);
  }
  
  /// 保存通知设置
  Future<bool> saveNotificationsEnabled(bool enabled) {
    return setBool(keyNotificationsEnabled, enabled);
  }
  
  /// 获取通知设置
  bool getNotificationsEnabled() {
    return getBool(keyNotificationsEnabled) ?? true;
  }
  
  /// 保存上次同步时间
  Future<bool> saveLastSyncTime(DateTime time) {
    return setString(keyLastSyncTime, time.toIso8601String());
  }
  
  /// 获取上次同步时间
  DateTime? getLastSyncTime() {
    final timeStr = getString(keyLastSyncTime);
    if (timeStr == null) return null;
    
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      AppLogger.error('解析同步时间失败', error: e);
      return null;
    }
  }
  
  /// 保存音频自动播放设置
  Future<bool> saveAutoPlayAudio(bool autoPlay) {
    return setBool(keyAutoPlayAudio, autoPlay);
  }
  
  /// 获取音频自动播放设置
  bool getAutoPlayAudio() {
    return getBool(keyAutoPlayAudio) ?? true;
  }
  
  /// 保存音频音量
  Future<bool> saveAudioVolume(double volume) {
    return setDouble(keyAudioVolume, volume);
  }
  
  /// 获取音频音量
  double getAudioVolume() {
    return getDouble(keyAudioVolume) ?? 0.8;
  }
  
  /// 保存仅WiFi加载媒体设置
  Future<bool> saveWifiOnlyMedia(bool wifiOnly) {
    return setBool(keyWifiOnlyMedia, wifiOnly);
  }
  
  /// 获取仅WiFi加载媒体设置
  bool getWifiOnlyMedia() {
    return getBool(keyWifiOnlyMedia) ?? false;
  }
  
  /// 清除用户数据
  Future<void> clearUserData() async {
    await remove(keyUserId);
    await remove(keyUsername);
    await remove(keyUserRole);
  }
}

/// SharedPreferences模块配置
@module
abstract class SharedPrefsModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}

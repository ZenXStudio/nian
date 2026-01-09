class ApiConstants {
  // Base URL - 根据环境配置
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  
  // API 端点
  // 认证相关
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getUserInfo = '/auth/me';
  
  // 方法相关
  static const String getMethods = '/methods';
  static const String getMethodDetail = '/methods/:id';
  static const String getRecommendedMethods = '/methods/recommendations';
  
  // 用户方法相关
  static const String getUserMethods = '/user/methods';
  static const String addUserMethod = '/user/methods';
  static const String removeUserMethod = '/user/methods/:id';
  
  // 练习记录相关
  static const String createPractice = '/user/practice';
  static const String getPractices = '/user/practice';
  static const String getPracticeStats = '/user/practice/stats';
  
  // 超时设置
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  
  // 存储键
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
}

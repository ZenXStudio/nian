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
  static const String getUserMethods = '/user-methods';
  static const String addUserMethod = '/user-methods';
  static const String removeUserMethod = '/user-methods/:id';
  
  // 练习记录相关
  static const String createPractice = '/practices';
  static const String getPractices = '/practices';
  static const String getPracticeStats = '/practices/stats';
  
  // 超时设置
  static const int connectTimeout = 15000; // 15秒
  static const int receiveTimeout = 15000; // 15秒
  
  // 存储键
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
}
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
  static const String getUserMethods = '/user-methods';
  static const String addUserMethod = '/user-methods';
  static const String removeUserMethod = '/user-methods/:id';
  
  // 练习记录相关
  static const String createPractice = '/practices';
  static const String getPractices = '/practices';
  static const String getPracticeStats = '/practices/stats';
  
  // 超时设置
  static const int connectTimeout = 15000; // 15秒
  static const int receiveTimeout = 15000; // 15秒
  
  // 存储键
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
}

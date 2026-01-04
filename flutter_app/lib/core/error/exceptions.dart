/// 应用程序异常基类
///
/// 所有自定义异常都应继承此类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message ${code != null ? "($code)" : ""}';
}

/// 服务器异常
///
/// 当API请求返回错误时抛出
class ServerException extends AppException {
  final int? statusCode;
  
  ServerException(
    super.message, {
    this.statusCode,
    super.code,
  });
  
  @override
  String toString() => 'ServerException: $message (HTTP $statusCode)';
}

/// 缓存异常
///
/// 当本地缓存操作失败时抛出
class CacheException extends AppException {
  CacheException(super.message, {super.code});
  
  @override
  String toString() => 'CacheException: $message';
}

/// 验证异常
///
/// 当输入验证失败时抛出
class ValidationException extends AppException {
  final Map<String, String>? errors;
  
  ValidationException(
    super.message, {
    this.errors,
    super.code,
  });
  
  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message - ${errors.toString()}';
    }
    return 'ValidationException: $message';
  }
}

/// 网络异常
///
/// 当网络连接失败时抛出
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
  
  @override
  String toString() => 'NetworkException: $message';
}

/// 认证异常
///
/// 当认证失败或Token过期时抛出
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code});
  
  @override
  String toString() => 'AuthenticationException: $message';
}

/// 授权异常
///
/// 当用户没有权限访问资源时抛出
class AuthorizationException extends AppException {
  AuthorizationException(super.message, {super.code});
  
  @override
  String toString() => 'AuthorizationException: $message';
}

/// 解析异常
///
/// 当数据解析失败时抛出
class ParseException extends AppException {
  ParseException(super.message, {super.code});
  
  @override
  String toString() => 'ParseException: $message';
}

/// 超时异常
///
/// 当操作超时时抛出
class TimeoutException extends AppException {
  TimeoutException(super.message, {super.code});
  
  @override
  String toString() => 'TimeoutException: $message';
}

import 'package:equatable/equatable.dart';

/// 失败基类
///
/// 用于表示业务层的失败状态
/// 使用Either<Failure, Data>模式返回结果
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message ${code != null ? "($code)" : ""}';
}

/// 服务器失败
///
/// 当服务器端返回错误时使用
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure(
    super.message, {
    this.statusCode,
    super.code,
  });
  
  @override
  List<Object?> get props => [message, code, statusCode];
  
  @override
  String toString() => 'ServerFailure: $message (HTTP $statusCode)';
}

/// 缓存失败
///
/// 当本地缓存操作失败时使用
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
  
  @override
  String toString() => 'CacheFailure: $message';
}

/// 验证失败
///
/// 当输入验证失败时使用
class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  
  const ValidationFailure(
    super.message, {
    this.errors,
    super.code,
  });
  
  @override
  List<Object?> get props => [message, code, errors];
  
  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationFailure: $message - ${errors.toString()}';
    }
    return 'ValidationFailure: $message';
  }
}

/// 网络失败
///
/// 当网络连接失败时使用
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
  
  @override
  String toString() => 'NetworkFailure: $message';
}

/// 认证失败
///
/// 当认证失败或Token过期时使用
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
  
  @override
  String toString() => 'AuthenticationFailure: $message';
}

/// 授权失败
///
/// 当用户没有权限时使用
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, {super.code});
  
  @override
  String toString() => 'AuthorizationFailure: $message';
}

/// 解析失败
///
/// 当数据解析失败时使用
class ParseFailure extends Failure {
  const ParseFailure(super.message, {super.code});
  
  @override
  String toString() => 'ParseFailure: $message';
}

/// 超时失败
///
/// 当操作超时时使用
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});
  
  @override
  String toString() => 'TimeoutFailure: $message';
}

/// 未知失败
///
/// 当发生未预期的错误时使用
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
  
  @override
  String toString() => 'UnknownFailure: $message';
}

/// 失败消息常量
class FailureMessages {
  // 网络相关
  static const String networkError = '网络连接失败，请检查您的网络';
  static const String networkTimeout = '网络请求超时，请稍后重试';
  static const String serverError = '服务器错误，请稍后重试';
  static const String noInternetConnection = '无网络连接';
  
  // 认证相关
  static const String unauthorized = '未授权，请先登录';
  static const String forbidden = '您没有权限执行此操作';
  static const String tokenExpired = '登录已过期，请重新登录';
  static const String invalidCredentials = '用户名或密码错误';
  
  // 数据相关
  static const String parseError = '数据解析失败';
  static const String cacheError = '缓存读取失败';
  static const String notFound = '请求的资源不存在';
  static const String validationError = '输入数据验证失败';
  
  // 通用
  static const String unknownError = '未知错误，请稍后重试';
  static const String operationCancelled = '操作已取消';
}

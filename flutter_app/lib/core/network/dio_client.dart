import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';
import '../../config/api_constants.dart';

/// Dio网络客户端封装
/// 
/// 提供统一的HTTP请求配置和拦截器
@lazySingleton
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  DioClient(this._secureStorage) {
    _dio = Dio(_buildBaseOptions());
    _setupInterceptors();
  }
  
  /// 获取Dio实例
  Dio get dio => _dio;
  
  /// 构建基础配置
  BaseOptions _buildBaseOptions() {
    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // 接受所有状态码，在拦截器中统一处理
        return status != null && status < 500;
      },
    );
  }
  
  /// 设置拦截器
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);
  }
  
  /// 更新认证令牌
  Future<void> updateToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  /// 清除认证令牌
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }
}

/// 认证拦截器
/// 
/// 自动在请求头中添加JWT令牌
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  
  _AuthInterceptor(this._secureStorage);
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 从安全存储中获取令牌
    final token = await _secureStorage.read(key: 'auth_token');
    
    if (token != null && token.isNotEmpty) {
      // 添加认证头
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 处理认证失败
    if (err.response?.statusCode == 401) {
      // 清除过期令牌
      _secureStorage.delete(key: 'auth_token');
      
      AppLogger.warning('认证失败，令牌已过期或无效');
    }
    
    handler.next(err);
  }
}

/// 日志拦截器
/// 
/// 记录所有HTTP请求和响应
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final url = options.uri.toString();
    
    AppLogger.info('[$method] 请求: $url');
    
    if (options.data != null) {
      AppLogger.debug('请求数据: ${options.data}');
    }
    
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug('查询参数: ${options.queryParameters}');
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method;
    final url = response.requestOptions.uri.toString();
    final statusCode = response.statusCode;
    
    AppLogger.network(
      method,
      url,
      statusCode: statusCode,
    );
    
    AppLogger.debug('响应数据: ${response.data}');
    
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final method = err.requestOptions.method;
    final url = err.requestOptions.uri.toString();
    
    AppLogger.error(
      '[$method] 请求失败: $url',
      error: err.message,
    );
    
    if (err.response != null) {
      AppLogger.error('错误响应: ${err.response?.data}');
    }
    
    handler.next(err);
  }
}

/// 错误拦截器
/// 
/// 统一处理和转换HTTP错误
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络连接';
        break;
      case DioExceptionType.sendTimeout:
        message = '请求超时，请稍后重试';
        break;
      case DioExceptionType.receiveTimeout:
        message = '响应超时，请稍后重试';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络';
        break;
      case DioExceptionType.badCertificate:
        message = '证书验证失败';
        break;
      case DioExceptionType.unknown:
      default:
        message = '未知错误: ${err.message}';
        break;
    }
    
    // 创建新的错误，包含友好的错误消息
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
      stackTrace: err.stackTrace,
    );
    
    handler.next(newError);
  }
  
  /// 处理HTTP状态码
  String _handleStatusCode(int? statusCode) {
    if (statusCode == null) {
      return '服务器无响应';
    }
    
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请先登录';
      case 403:
        return '没有权限访问';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 409:
        return '数据冲突';
      case 422:
        return '数据验证失败';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return '客户端错误 ($statusCode)';
        } else if (statusCode >= 500) {
          return '服务器错误 ($statusCode)';
        }
        return '未知错误 ($statusCode)';
    }
  }
}

/// Dio模块配置
/// 
/// 用于依赖注入配置
@module
abstract class DioModule {
  /// 提供FlutterSecureStorage实例
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  
  /// 提供Dio实例
  @lazySingleton
  Dio dio(DioClient dioClient) => dioClient.dio;
}

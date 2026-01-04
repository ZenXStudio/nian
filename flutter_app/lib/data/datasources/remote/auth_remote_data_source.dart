import 'package:dio/dio.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/models/user_model.dart';
import 'package:mental_app/core/error/exceptions.dart';

/// 认证远程数据源
class AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  /// 用户登录
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 用户注册
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String nickname,
  ) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'nickname': nickname,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取当前用户
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] ?? '请求失败';
      
      if (statusCode == 401) {
        return AuthenticationException(message);
      } else if (statusCode == 400) {
        return ValidationException(message);
      }
      return ServerException(message, statusCode: statusCode);
    }
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('请求超时');
    }
    
    return NetworkException('网络连接失败');
  }
}

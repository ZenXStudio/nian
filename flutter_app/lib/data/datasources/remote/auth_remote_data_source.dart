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
    String? nickname,
  ) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'password': password,
      };
      if (nickname != null && nickname.isNotEmpty) {
        data['nickname'] = nickname;
      }
      
      final response = await dioClient.post(
        '/auth/register',
        data: data,
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
      final responseData = response.data as Map<String, dynamic>;
      // API返回格式: {success: true, data: {...}}
      final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 修改密码
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await dioClient.post(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 更新用户资料
  Future<UserModel> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nickname != null) data['nickname'] = nickname;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      
      final response = await dioClient.patch('/auth/profile', data: data);
      final responseData = response.data as Map<String, dynamic>;
      // API返回格式: {success: true, data: {...}}
      final userData = responseData['data'] as Map<String, dynamic>? ?? responseData;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      String message = '请求失败';
      
      // 安全地提取错误消息
      // API错误格式: {success: false, error: {code: ..., message: ...}}
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic>) {
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          message = (errorObj['message'] as String?) ?? '请求失败';
        } else {
          message = (responseData['message'] as String?) ?? '请求失败';
        }
      } else if (responseData is String) {
        message = responseData;
      }
      
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

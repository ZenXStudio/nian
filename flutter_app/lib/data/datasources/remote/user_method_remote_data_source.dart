import 'package:dio/dio.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/models/user_method_model.dart';
import 'package:mental_app/core/error/exceptions.dart';

/// 用户方法远程数据源
class UserMethodRemoteDataSource {
  final DioClient dioClient;

  UserMethodRemoteDataSource(this.dioClient);

  /// 获取用户方法列表
  Future<List<UserMethodModel>> getUserMethods() async {
    try {
      final response = await dioClient.get('/user-methods');
      final data = response.data['data'] as List;
      return data.map((json) => UserMethodModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 添加方法到个人库
  Future<UserMethodModel> addMethodToLibrary({
    required int methodId,
    String? personalGoal,
  }) async {
    try {
      final response = await dioClient.post(
        '/user-methods',
        data: {
          'methodId': methodId,
          if (personalGoal != null) 'personalGoal': personalGoal,
        },
      );
      return UserMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 更新用户方法
  Future<UserMethodModel> updateUserMethod({
    required int userMethodId,
    String? personalGoal,
    bool? isFavorite,
  }) async {
    try {
      final response = await dioClient.put(
        '/user-methods/$userMethodId',
        data: {
          if (personalGoal != null) 'personalGoal': personalGoal,
          if (isFavorite != null) 'isFavorite': isFavorite,
        },
      );
      return UserMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 删除用户方法
  Future<void> deleteUserMethod(int userMethodId) async {
    try {
      await dioClient.delete('/user-methods/$userMethodId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] ?? '请求失败';
      return ServerException(message, statusCode: statusCode);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('请求超时');
    }

    return NetworkException('网络连接失败');
  }
}

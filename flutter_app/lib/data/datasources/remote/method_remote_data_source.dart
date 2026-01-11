import 'package:dio/dio.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/models/method_model.dart';
import 'package:mental_app/core/error/exceptions.dart';

/// 方法远程数据源
class MethodRemoteDataSource {
  final DioClient dioClient;

  MethodRemoteDataSource(this.dioClient);

  /// 获取方法列表
  Future<List<MethodModel>> getMethods({
    String? category,
    String? difficulty,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dioClient.get(
        '/methods',
        queryParameters: {
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          'page': page,
          'pageSize': pageSize,
        },
      );
      // API返回格式: {success: true, data: {list: [...], total, page, pageSize}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      final list = data['list'] as List;
      return list.map((json) => MethodModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取方法详情
  Future<MethodModel> getMethodDetail(int methodId) async {
    try {
      final response = await dioClient.get('/methods/$methodId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
      return MethodModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 搜索方法
  Future<List<MethodModel>> searchMethods({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dioClient.get(
        '/methods/search',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'pageSize': pageSize,
        },
      );
      // API返回格式: {success: true, data: {list: [...], total, page, pageSize}}
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      final list = data['list'] as List;
      return list.map((json) => MethodModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      String message = '请求失败';
      
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic>) {
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          message = (errorObj['message'] as String?) ?? '请求失败';
        } else {
          message = (responseData['message'] as String?) ?? '请求失败';
        }
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

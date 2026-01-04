import 'package:dio/dio.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/models/practice_record_model.dart';
import 'package:mental_app/domain/entities/practice_stats.dart';
import 'package:mental_app/core/error/exceptions.dart';

/// 练习远程数据源
class PracticeRemoteDataSource {
  final DioClient dioClient;

  PracticeRemoteDataSource(this.dioClient);

  /// 记录练习
  Future<PracticeRecordModel> recordPractice({
    required int methodId,
    required int durationMinutes,
    required int moodBefore,
    required int moodAfter,
    String? notes,
  }) async {
    try {
      final response = await dioClient.post(
        '/practices',
        data: {
          'methodId': methodId,
          'durationMinutes': durationMinutes,
          'moodBefore': moodBefore,
          'moodAfter': moodAfter,
          if (notes != null) 'notes': notes,
        },
      );
      return PracticeRecordModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取练习历史
  Future<List<PracticeRecordModel>> getPracticeHistory({
    int page = 1,
    int pageSize = 20,
    int? methodId,
  }) async {
    try {
      final response = await dioClient.get(
        '/practices',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (methodId != null) 'methodId': methodId,
        },
      );
      final data = response.data['data'] as List;
      return data.map((json) => PracticeRecordModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取练习统计
  Future<PracticeStats> getPracticeStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await dioClient.get(
        '/practices/stats',
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      final data = response.data as Map<String, dynamic>;
      return PracticeStats(
        totalCount: data['totalCount'] as int,
        totalMinutes: data['totalMinutes'] as int,
        averageMoodImprovement: (data['averageMoodImprovement'] as num).toDouble(),
        currentStreak: data['currentStreak'] as int,
        longestStreak: data['longestStreak'] as int,
      );
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

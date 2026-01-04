import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/domain/entities/practice_record.dart';
import 'package:mental_app/domain/entities/practice_stats.dart';

/// 练习Repository接口
///
/// 定义练习记录相关的数据访问接口
abstract class PracticeRepository {
  /// 记录练习
  ///
  /// [methodId] 方法ID
  /// [durationMinutes] 练习时长
  /// [moodBefore] 练习前心理状态
  /// [moodAfter] 练习后心理状态
  /// [notes] 练习笔记（可选）
  /// 返回 [PracticeRecord] 或 [Failure]
  Future<Either<Failure, PracticeRecord>> recordPractice({
    required int methodId,
    required int durationMinutes,
    required int moodBefore,
    required int moodAfter,
    String? notes,
  });

  /// 获取练习历史
  ///
  /// [page] 页码
  /// [pageSize] 每页数量
  /// [methodId] 方法ID筛选（可选）
  /// 返回 [List<PracticeRecord>] 或 [Failure]
  Future<Either<Failure, List<PracticeRecord>>> getPracticeHistory({
    int page = 1,
    int pageSize = 20,
    int? methodId,
  });

  /// 获取练习统计
  ///
  /// [startDate] 开始日期（可选）
  /// [endDate] 结束日期（可选）
  /// 返回 [PracticeStats] 或 [Failure]
  Future<Either<Failure, PracticeStats>> getPracticeStats({
    DateTime? startDate,
    DateTime? endDate,
  });
}

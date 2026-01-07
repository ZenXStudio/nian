import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/exceptions.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/data/datasources/remote/practice_remote_data_source.dart';
import 'package:mental_app/domain/entities/practice_record.dart';
import 'package:mental_app/domain/entities/practice_stats.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';

/// 练习Repository实现
class PracticeRepositoryImpl implements PracticeRepository {
  final PracticeRemoteDataSource remoteDataSource;

  PracticeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PracticeRecord>> recordPractice({
    required int methodId,
    required int durationMinutes,
    required int moodBefore,
    required int moodAfter,
    String? notes,
  }) async {
    try {
      final record = await remoteDataSource.recordPractice(
        methodId: methodId,
        durationMinutes: durationMinutes,
        moodBefore: moodBefore,
        moodAfter: moodAfter,
        notes: notes,
      );
      return Right(record);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('记录练习失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PracticeRecord>>> getPracticeHistory({
    int page = 1,
    int pageSize = 20,
    int? methodId,
  }) async {
    try {
      final records = await remoteDataSource.getPracticeHistory(
        page: page,
        pageSize: pageSize,
        methodId: methodId,
      );
      return Right(records);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取练习历史失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PracticeStats>> getPracticeStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await remoteDataSource.getPracticeStats(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(stats);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取练习统计失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PracticeStats>> getPracticeStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return getPracticeStats(startDate: startDate, endDate: endDate);
  }
}

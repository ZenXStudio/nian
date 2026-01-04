import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/exceptions.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/data/datasources/remote/method_remote_data_source.dart';
import 'package:mental_app/domain/entities/method.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';

/// 方法Repository实现
class MethodRepositoryImpl implements MethodRepository {
  final MethodRemoteDataSource remoteDataSource;

  MethodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Method>>> getMethods({
    String? category,
    String? difficulty,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final methods = await remoteDataSource.getMethods(
        category: category,
        difficulty: difficulty,
        page: page,
        pageSize: pageSize,
      );
      return Right(methods);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取方法列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Method>> getMethodDetail(int methodId) async {
    try {
      final method = await remoteDataSource.getMethodDetail(methodId);
      return Right(method);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取方法详情失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Method>>> searchMethods({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final methods = await remoteDataSource.searchMethods(
        keyword: keyword,
        page: page,
        pageSize: pageSize,
      );
      return Right(methods);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('搜索方法失败: ${e.toString()}'));
    }
  }
}

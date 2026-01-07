import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/exceptions.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/data/datasources/remote/user_method_remote_data_source.dart';
import 'package:mental_app/domain/entities/user_method.dart';
import 'package:mental_app/domain/repositories/user_method_repository.dart';

/// 用户方法Repository实现
class UserMethodRepositoryImpl implements UserMethodRepository {
  final UserMethodRemoteDataSource remoteDataSource;

  UserMethodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserMethod>>> getUserMethods() async {
    try {
      final userMethods = await remoteDataSource.getUserMethods();
      return Right(userMethods);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取个人方法列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserMethod>> addMethodToLibrary({
    required int methodId,
    String? personalGoal,
  }) async {
    try {
      final userMethod = await remoteDataSource.addMethodToLibrary(
        methodId: methodId,
        personalGoal: personalGoal,
      );
      return Right(userMethod);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('添加方法失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserMethod>> updateUserMethod({
    required int userMethodId,
    String? personalGoal,
    bool? isFavorite,
  }) async {
    try {
      final userMethod = await remoteDataSource.updateUserMethod(
        userMethodId: userMethodId,
        personalGoal: personalGoal,
        isFavorite: isFavorite,
      );
      return Right(userMethod);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('更新方法失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeUserMethod(int userMethodId) async {
    try {
      await remoteDataSource.deleteUserMethod(userMethodId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('删除方法失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserMethod(int userMethodId) async {
    return removeUserMethod(userMethodId);
  }
}

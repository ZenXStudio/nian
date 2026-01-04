import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/exceptions.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/core/storage/secure_storage_helper.dart';
import 'package:mental_app/data/datasources/remote/auth_remote_data_source.dart';
import 'package:mental_app/data/models/user_model.dart';
import 'package:mental_app/domain/entities/user.dart';
import 'package:mental_app/domain/repositories/auth_repository.dart';

/// 认证Repository实现
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageHelper secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email, password);
      final token = result['token'] as String;
      final userJson = result['user'] as Map<String, dynamic>;
      
      // 保存Token
      await secureStorage.saveToken(token);
      
      // 返回用户信息
      final user = UserModel.fromJson(userJson);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('登录失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final result = await remoteDataSource.register(email, password, nickname);
      final token = result['token'] as String;
      final userJson = result['user'] as Map<String, dynamic>;
      
      // 保存Token
      await secureStorage.saveToken(token);
      
      // 返回用户信息
      final user = UserModel.fromJson(userJson);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('注册失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthenticationException catch (e) {
      await secureStorage.deleteToken(); // Token无效，清除
      return Left(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('获取用户信息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.deleteToken();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('登出失败: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await secureStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

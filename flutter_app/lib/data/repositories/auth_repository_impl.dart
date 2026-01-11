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
      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) {
        return Left(UnknownFailure('登录失败: 无效的响应数据'));
      }
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      
      if (token == null || userJson == null) {
        return Left(UnknownFailure('登录失败: 缺少必要数据'));
      }
      
      // 保存Token
      await secureStorage.saveAuthToken(token);
      
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
    String? nickname,
  }) async {
    try {
      final result = await remoteDataSource.register(email, password, nickname);
      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) {
        return Left(UnknownFailure('注册失败: 无效的响应数据'));
      }
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>?;
      
      if (token == null || userJson == null) {
        return Left(UnknownFailure('注册失败: 缺少必要数据'));
      }
      
      // 保存Token
      await secureStorage.saveAuthToken(token);
      
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
      await secureStorage.deleteAuthToken(); // Token无效，清除
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
      await secureStorage.deleteAuthToken();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('登出失败: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await secureStorage.getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(oldPassword, newPassword);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('修改密码失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('更新资料失败: ${e.toString()}'));
    }
  }
}

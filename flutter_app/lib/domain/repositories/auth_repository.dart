import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/domain/entities/user.dart';

/// 认证Repository接口
///
/// 定义认证相关的数据访问接口
abstract class AuthRepository {
  /// 用户登录
  ///
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// 返回 [User] 或 [Failure]
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// 用户注册
  ///
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// [nickname] 用户昵称
  /// 返回 [User] 或 [Failure]
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String nickname,
  });

  /// 获取当前用户信息
  ///
  /// 返回 [User] 或 [Failure]
  Future<Either<Failure, User>> getCurrentUser();

  /// 用户登出
  ///
  /// 返回 [void] 或 [Failure]
  Future<Either<Failure, void>> logout();

  /// 检查是否已登录
  ///
  /// 返回 true 如果有有效的Token
  Future<bool> isLoggedIn();

  /// 修改密码
  ///
  /// [旧密码] 旧密码
  /// [新密码] 新密码
  /// 返回 [void] 或 [Failure]
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// 更新用户资料
  ///
  /// [nickname] 用户昵称（可选）
  /// [avatarUrl] 头像URL（可选）
  /// 返回 [User] 或 [Failure]
  Future<Either<Failure, User>> updateProfile({
    String? nickname,
    String? avatarUrl,
  });
}

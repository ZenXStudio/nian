import 'package:dartz/dartz.dart';
import 'package:mental_app/core/error/failures.dart';
import 'package:mental_app/domain/entities/user_method.dart';

/// 用户方法Repository接口
///
/// 定义用户方法库相关的数据访问接口
abstract class UserMethodRepository {
  /// 获取用户的方法列表
  ///
  /// 返回 [List<UserMethod>] 或 [Failure]
  Future<Either<Failure, List<UserMethod>>> getUserMethods();

  /// 添加方法到个人库
  ///
  /// [methodId] 方法ID
  /// [personalGoal] 个人目标（可选）
  /// 返回 [UserMethod] 或 [Failure]
  Future<Either<Failure, UserMethod>> addMethodToLibrary({
    required int methodId,
    String? personalGoal,
  });

  /// 更新用户方法
  ///
  /// [userMethodId] 用户方法ID
  /// [personalGoal] 个人目标（可选）
  /// [isFavorite] 是否收藏（可选）
  /// 返回 [UserMethod] 或 [Failure]
  Future<Either<Failure, UserMethod>> updateUserMethod({
    required int userMethodId,
    String? personalGoal,
    bool? isFavorite,
  });

  /// 从个人库移除方法
  ///
  /// [userMethodId] 用户方法ID
  /// 返回 [void] 或 [Failure]
  Future<Either<Failure, void>> removeUserMethod(int userMethodId);
}

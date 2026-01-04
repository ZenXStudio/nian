import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 用户方法实体
///
/// 表示用户添加到个人库的方法
class UserMethod extends Equatable {
  /// 记录ID
  final int id;
  
  /// 用户ID
  final int userId;
  
  /// 方法ID
  final int methodId;
  
  /// 关联的方法信息
  final Method method;
  
  /// 个人目标
  final String? personalGoal;
  
  /// 是否收藏
  final bool isFavorite;
  
  /// 练习次数
  final int practiceCount;
  
  /// 添加时间
  final DateTime addedAt;

  const UserMethod({
    required this.id,
    required this.userId,
    required this.methodId,
    required this.method,
    this.personalGoal,
    required this.isFavorite,
    required this.practiceCount,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        methodId,
        method,
        personalGoal,
        isFavorite,
        practiceCount,
        addedAt,
      ];

  @override
  String toString() =>
      'UserMethod(id: $id, methodId: $methodId, practiceCount: $practiceCount)';
}

import 'package:mental_app/domain/entities/user_method.dart';
import 'package:mental_app/data/models/method_model.dart';

/// 用户方法Model
class UserMethodModel extends UserMethod {
  const UserMethodModel({
    required super.id,
    required super.userId,
    required super.methodId,
    required super.method,
    super.personalGoal,
    required super.isFavorite,
    required super.practiceCount,
    required super.addedAt,
  });

  /// 从JSON创建
  factory UserMethodModel.fromJson(Map<String, dynamic> json) {
    return UserMethodModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      methodId: json['methodId'] as int,
      method: MethodModel.fromJson(json['method'] as Map<String, dynamic>),
      personalGoal: json['personalGoal'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      practiceCount: json['practiceCount'] as int? ?? 0,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'methodId': methodId,
      'method': (method as MethodModel).toJson(),
      'personalGoal': personalGoal,
      'isFavorite': isFavorite,
      'practiceCount': practiceCount,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

/// 用户方法Model
class UserMethodModel extends UserMethod {
  const UserMethodModel({
    required super.id,
    required super.userId,
    required super.methodId,
    required super.method,
    super.personalGoal,
    required super.isFavorite,
    required super.practiceCount,
    required super.addedAt,
  });

  /// 从JSON创建
  factory UserMethodModel.fromJson(Map<String, dynamic> json) {
    return UserMethodModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      methodId: json['methodId'] as int,
      method: MethodModel.fromJson(json['method'] as Map<String, dynamic>),
      personalGoal: json['personalGoal'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      practiceCount: json['practiceCount'] as int? ?? 0,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'methodId': methodId,
      'method': (method as MethodModel).toJson(),
      'personalGoal': personalGoal,
      'isFavorite': isFavorite,
      'practiceCount': practiceCount,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

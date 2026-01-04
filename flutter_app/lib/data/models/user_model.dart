import 'package:mental_app/domain/entities/user.dart';

/// 用户数据模型
///
/// 用于JSON序列化的数据模型
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nickname,
    required super.createdAt,
  });

  /// 从JSON创建UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 转换为User实体
  User toEntity() {
    return User(
      id: id,
      email: email,
      nickname: nickname,
      createdAt: createdAt,
    );
  }
}

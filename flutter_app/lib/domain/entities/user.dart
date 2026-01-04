import 'package:equatable/equatable.dart';

/// 用户实体
///
/// 表示系统中的用户
class User extends Equatable {
  /// 用户ID
  final int id;
  
  /// 邮箱
  final String email;
  
  /// 昵称
  final String nickname;
  
  /// 注册时间
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, nickname, createdAt];

  @override
  String toString() => 'User(id: $id, email: $email, nickname: $nickname)';
}

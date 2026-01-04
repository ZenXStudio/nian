import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/user.dart';

/// 认证状态基类
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 加载中状态
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 已认证状态
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// 未认证状态
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// 错误状态
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

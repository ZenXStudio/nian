import 'package:equatable/equatable.dart';

/// 认证事件基类
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 应用启动事件
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// 登录请求事件
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// 注册请求事件
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  List<Object?> get props => [email, password, nickname];
}

/// 登出请求事件
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

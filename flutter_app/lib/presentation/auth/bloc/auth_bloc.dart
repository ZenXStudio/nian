import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/auth_repository.dart';
import 'package:mental_app/presentation/auth/bloc/auth_event.dart';
import 'package:mental_app/presentation/auth/bloc/auth_state.dart';

/// 认证BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// 处理应用启动
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(const Unauthenticated()),
        (user) => emit(Authenticated(user)),
      );
    } else {
      emit(const Unauthenticated());
    }
  }

  /// 处理登录请求
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// 处理注册请求
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final result = await authRepository.register(
      email: event.email,
      password: event.password,
      nickname: event.nickname,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// 处理登出请求
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const Unauthenticated());
  }
}

import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法详情状态基类
abstract class MethodDetailState extends Equatable {
  const MethodDetailState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MethodDetailInitial extends MethodDetailState {
  const MethodDetailInitial();
}

/// 加载中
class MethodDetailLoading extends MethodDetailState {
  const MethodDetailLoading();
}

/// 加载成功
class MethodDetailLoaded extends MethodDetailState {
  final Method method;

  const MethodDetailLoaded(this.method);

  @override
  List<Object?> get props => [method];
}

/// 加载失败
class MethodDetailError extends MethodDetailState {
  final String message;

  const MethodDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 成功添加到个人库
class MethodAddedToLibrary extends MethodDetailState {
  final Method method;

  const MethodAddedToLibrary(this.method);

  @override
  List<Object?> get props => [method];
}

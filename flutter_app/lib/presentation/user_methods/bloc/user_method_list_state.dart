import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/user_method.dart';

/// 个人方法库列表状态基类
abstract class UserMethodListState extends Equatable {
  const UserMethodListState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class UserMethodListInitial extends UserMethodListState {
  const UserMethodListInitial();
}

/// 加载中
class UserMethodListLoading extends UserMethodListState {
  const UserMethodListLoading();
}

/// 加载成功
class UserMethodListLoaded extends UserMethodListState {
  final List<UserMethod> methods;
  final String? currentCategory;
  final bool hasReachedMax;

  const UserMethodListLoaded({
    required this.methods,
    this.currentCategory,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [methods, currentCategory, hasReachedMax];

  UserMethodListLoaded copyWith({
    List<UserMethod>? methods,
    String? currentCategory,
    bool? hasReachedMax,
  }) {
    return UserMethodListLoaded(
      methods: methods ?? this.methods,
      currentCategory: currentCategory ?? this.currentCategory,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// 加载失败
class UserMethodListError extends UserMethodListState {
  final String message;

  const UserMethodListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 操作成功（收藏、更新、删除）
class UserMethodActionSuccess extends UserMethodListState {
  final String message;
  final List<UserMethod> methods;

  const UserMethodActionSuccess({
    required this.message,
    required this.methods,
  });

  @override
  List<Object?> get props => [message, methods];
}
import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/user_method.dart';

/// 个人方法库列表状态基类
abstract class UserMethodListState extends Equatable {
  const UserMethodListState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class UserMethodListInitial extends UserMethodListState {
  const UserMethodListInitial();
}

/// 加载中
class UserMethodListLoading extends UserMethodListState {
  const UserMethodListLoading();
}

/// 加载成功
class UserMethodListLoaded extends UserMethodListState {
  final List<UserMethod> methods;
  final String? currentCategory;
  final bool hasReachedMax;

  const UserMethodListLoaded({
    required this.methods,
    this.currentCategory,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [methods, currentCategory, hasReachedMax];

  UserMethodListLoaded copyWith({
    List<UserMethod>? methods,
    String? currentCategory,
    bool? hasReachedMax,
  }) {
    return UserMethodListLoaded(
      methods: methods ?? this.methods,
      currentCategory: currentCategory ?? this.currentCategory,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// 加载失败
class UserMethodListError extends UserMethodListState {
  final String message;

  const UserMethodListError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 操作成功（收藏、更新、删除）
class UserMethodActionSuccess extends UserMethodListState {
  final String message;
  final List<UserMethod> methods;

  const UserMethodActionSuccess({
    required this.message,
    required this.methods,
  });

  @override
  List<Object?> get props => [message, methods];
}

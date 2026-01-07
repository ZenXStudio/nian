import 'package:equatable/equatable.dart';

/// 个人方法库列表事件基类
abstract class UserMethodListEvent extends Equatable {
  const UserMethodListEvent();

  @override
  List<Object?> get props => [];
}

/// 加载个人方法列表
class LoadUserMethods extends UserMethodListEvent {
  const LoadUserMethods();
}

/// 刷新个人方法列表
class RefreshUserMethods extends UserMethodListEvent {
  const RefreshUserMethods();
}

/// 按分类筛选
class FilterUserMethodsByCategory extends UserMethodListEvent {
  final String? category;

  const FilterUserMethodsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// 切换收藏状态
class ToggleFavorite extends UserMethodListEvent {
  final int userMethodId;

  const ToggleFavorite(this.userMethodId);

  @override
  List<Object?> get props => [userMethodId];
}

/// 更新个人目标
class UpdateUserMethodGoal extends UserMethodListEvent {
  final int userMethodId;
  final String goal;

  const UpdateUserMethodGoal({
    required this.userMethodId,
    required this.goal,
  });

  @override
  List<Object?> get props => [userMethodId, goal];
}

/// 删除个人方法
class DeleteUserMethod extends UserMethodListEvent {
  final int userMethodId;

  const DeleteUserMethod(this.userMethodId);

  @override
  List<Object?> get props => [userMethodId];
}

/// 个人方法库列表事件基类
abstract class UserMethodListEvent extends Equatable {
  const UserMethodListEvent();

  @override
  List<Object?> get props => [];
}

/// 加载个人方法列表
class LoadUserMethods extends UserMethodListEvent {
  const LoadUserMethods();
}

/// 刷新个人方法列表
class RefreshUserMethods extends UserMethodListEvent {
  const RefreshUserMethods();
}

/// 按分类筛选
class FilterUserMethodsByCategory extends UserMethodListEvent {
  final String? category;

  const FilterUserMethodsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// 切换收藏状态
class ToggleFavorite extends UserMethodListEvent {
  final int userMethodId;

  const ToggleFavorite(this.userMethodId);

  @override
  List<Object?> get props => [userMethodId];
}

/// 更新个人目标
class UpdateUserMethodGoal extends UserMethodListEvent {
  final int userMethodId;
  final String goal;

  const UpdateUserMethodGoal({
    required this.userMethodId,
    required this.goal,
  });

  @override
  List<Object?> get props => [userMethodId, goal];
}

/// 删除个人方法
class DeleteUserMethod extends UserMethodListEvent {
  final int userMethodId;

  const DeleteUserMethod(this.userMethodId);

  @override
  List<Object?> get props => [userMethodId];
}

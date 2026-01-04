import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法列表事件基类
abstract class MethodListEvent extends Equatable {
  const MethodListEvent();

  @override
  List<Object?> get props => [];
}

/// 加载方法列表
class LoadMethods extends MethodListEvent {
  final String? category;
  final String? difficulty;
  final int page;
  final int pageSize;

  const LoadMethods({
    this.category,
    this.difficulty,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [category, difficulty, page, pageSize];
}

/// 按分类筛选
class FilterMethodsByCategory extends MethodListEvent {
  final String? category;

  const FilterMethodsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// 加载更多方法
class LoadMoreMethods extends MethodListEvent {
  const LoadMoreMethods();
}

/// 刷新方法列表
class RefreshMethods extends MethodListEvent {
  const RefreshMethods();
}
import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法列表事件基类
abstract class MethodListEvent extends Equatable {
  const MethodListEvent();

  @override
  List<Object?> get props => [];
}

/// 加载方法列表
class LoadMethods extends MethodListEvent {
  final String? category;
  final String? difficulty;
  final int page;
  final int pageSize;

  const LoadMethods({
    this.category,
    this.difficulty,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [category, difficulty, page, pageSize];
}

/// 按分类筛选
class FilterMethodsByCategory extends MethodListEvent {
  final String? category;

  const FilterMethodsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// 加载更多方法
class LoadMoreMethods extends MethodListEvent {
  const LoadMoreMethods();
}

/// 刷新方法列表
class RefreshMethods extends MethodListEvent {
  const RefreshMethods();
}

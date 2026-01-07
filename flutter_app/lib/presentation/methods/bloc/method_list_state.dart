import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法列表状态基类
abstract class MethodListState extends Equatable {
  const MethodListState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MethodListInitial extends MethodListState {
  const MethodListInitial();
}

/// 加载中
class MethodListLoading extends MethodListState {
  const MethodListLoading();
}

/// 加载成功
class MethodListLoaded extends MethodListState {
  final List<Method> methods;
  final int currentPage;
  final bool hasMore;
  final String? currentCategory;

  const MethodListLoaded({
    required this.methods,
    this.currentPage = 1,
    this.hasMore = true,
    this.currentCategory,
  });

  @override
  List<Object?> get props => [methods, currentPage, hasMore, currentCategory];

  MethodListLoaded copyWith({
    List<Method>? methods,
    int? currentPage,
    bool? hasMore,
    String? currentCategory,
  }) {
    return MethodListLoaded(
      methods: methods ?? this.methods,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }
}

/// 加载更多中
class MethodListLoadingMore extends MethodListState {
  final List<Method> methods;
  final int currentPage;
  final String? currentCategory;

  const MethodListLoadingMore({
    required this.methods,
    required this.currentPage,
    this.currentCategory,
  });

  @override
  List<Object?> get props => [methods, currentPage, currentCategory];
}

/// 加载失败
class MethodListError extends MethodListState {
  final String message;

  const MethodListError(this.message);

  @override
  List<Object?> get props => [message];
}

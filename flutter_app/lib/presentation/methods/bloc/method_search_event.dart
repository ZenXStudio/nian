import 'package:equatable/equatable.dart';

/// 方法搜索事件基类
abstract class MethodSearchEvent extends Equatable {
  const MethodSearchEvent();

  @override
  List<Object?> get props => [];
}

/// 搜索方法事件
class SearchMethods extends MethodSearchEvent {
  final String query;
  final String? category;

  const SearchMethods({
    required this.query,
    this.category,
  });

  @override
  List<Object?> get props => [query, category];
}

/// 清空搜索事件
class ClearSearch extends MethodSearchEvent {
  const ClearSearch();
}

/// 加载搜索历史事件
class LoadSearchHistory extends MethodSearchEvent {
  const LoadSearchHistory();
}

/// 添加到搜索历史事件
class AddToSearchHistory extends MethodSearchEvent {
  final String query;

  const AddToSearchHistory(this.query);

  @override
  List<Object?> get props => [query];
}

/// 清除搜索历史事件
class ClearSearchHistory extends MethodSearchEvent {
  const ClearSearchHistory();
}

/// 方法搜索事件基类
abstract class MethodSearchEvent extends Equatable {
  const MethodSearchEvent();

  @override
  List<Object?> get props => [];
}

/// 搜索方法事件
class SearchMethods extends MethodSearchEvent {
  final String query;
  final String? category;

  const SearchMethods({
    required this.query,
    this.category,
  });

  @override
  List<Object?> get props => [query, category];
}

/// 清空搜索事件
class ClearSearch extends MethodSearchEvent {
  const ClearSearch();
}

/// 加载搜索历史事件
class LoadSearchHistory extends MethodSearchEvent {
  const LoadSearchHistory();
}

/// 添加到搜索历史事件
class AddToSearchHistory extends MethodSearchEvent {
  final String query;

  const AddToSearchHistory(this.query);

  @override
  List<Object?> get props => [query];
}

/// 清除搜索历史事件
class ClearSearchHistory extends MethodSearchEvent {
  const ClearSearchHistory();
}

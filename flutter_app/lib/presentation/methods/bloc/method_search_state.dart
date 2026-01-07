import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 方法搜索状态基类
abstract class MethodSearchState extends Equatable {
  const MethodSearchState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MethodSearchInitial extends MethodSearchState {
  final List<String> searchHistory;

  const MethodSearchInitial({this.searchHistory = const []});

  @override
  List<Object?> get props => [searchHistory];
}

/// 搜索中状态
class MethodSearchLoading extends MethodSearchState {
  const MethodSearchLoading();
}

/// 搜索成功状态
class MethodSearchLoaded extends MethodSearchState {
  final List<Method> results;
  final String query;

  const MethodSearchLoaded({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

/// 搜索失败状态
class MethodSearchError extends MethodSearchState {
  final String message;

  const MethodSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 搜索历史已加载状态
class SearchHistoryLoaded extends MethodSearchState {
  final List<String> history;

  const SearchHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

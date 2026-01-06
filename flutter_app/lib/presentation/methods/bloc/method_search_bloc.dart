import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/core/utils/shared_prefs_helper.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';
import 'package:mental_app/presentation/methods/bloc/method_search_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_search_state.dart';

/// 方法搜索 BLoC
class MethodSearchBloc extends Bloc<MethodSearchEvent, MethodSearchState> {
  final MethodRepository methodRepository;
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;

  MethodSearchBloc({required this.methodRepository})
      : super(const MethodSearchInitial()) {
    on<SearchMethods>(_onSearchMethods);
    on<ClearSearch>(_onClearSearch);
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<AddToSearchHistory>(_onAddToSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
  }

  /// 搜索方法
  Future<void> _onSearchMethods(
    SearchMethods event,
    Emitter<MethodSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const MethodSearchInitial());
      return;
    }

    emit(const MethodSearchLoading());

    final result = await methodRepository.getMethods(
      category: event.category,
      page: 1,
      pageSize: 50, // 搜索返回更多结果
    );

    result.fold(
      (failure) => emit(MethodSearchError(failure.message)),
      (methods) {
        // 客户端过滤：根据关键词搜索方法名称和描述
        final query = event.query.toLowerCase();
        final filteredMethods = methods.where((method) {
          final nameMatch = method.name.toLowerCase().contains(query);
          final descMatch = method.description.toLowerCase().contains(query);
          return nameMatch || descMatch;
        }).toList();

        emit(MethodSearchLoaded(
          results: filteredMethods,
          query: event.query,
        ));

        // 添加到搜索历史
        add(AddToSearchHistory(event.query));
      },
    );
  }

  /// 清空搜索
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<MethodSearchState> emit,
  ) async {
    final history = await _loadSearchHistory();
    emit(MethodSearchInitial(searchHistory: history));
  }

  /// 加载搜索历史
  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<MethodSearchState> emit,
  ) async {
    final history = await _loadSearchHistory();
    emit(SearchHistoryLoaded(history));
  }

  /// 添加到搜索历史
  Future<void> _onAddToSearchHistory(
    AddToSearchHistory event,
    Emitter<MethodSearchState> emit,
  ) async {
    final prefs = await SharedPrefsHelper.getInstance();
    final history = await _loadSearchHistory();

    // 移除重复项
    history.remove(event.query);

    // 添加到首位
    history.insert(0, event.query);

    // 限制数量
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }

    // 保存
    await prefs.setStringList(_searchHistoryKey, history);
  }

  /// 清除搜索历史
  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<MethodSearchState> emit,
  ) async {
    final prefs = await SharedPrefsHelper.getInstance();
    await prefs.remove(_searchHistoryKey);
    emit(const MethodSearchInitial(searchHistory: []));
  }

  /// 从SharedPreferences加载搜索历史
  Future<List<String>> _loadSearchHistory() async {
    final prefs = await SharedPrefsHelper.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }
}

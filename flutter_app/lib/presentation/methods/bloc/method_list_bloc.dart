import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_state.dart';

/// 方法列表BLoC
class MethodListBloc extends Bloc<MethodListEvent, MethodListState> {
  final MethodRepository methodRepository;

  MethodListBloc({required this.methodRepository})
      : super(const MethodListInitial()) {
    on<LoadMethods>(_onLoadMethods);
    on<FilterMethodsByCategory>(_onFilterMethodsByCategory);
    on<LoadMoreMethods>(_onLoadMoreMethods);
    on<RefreshMethods>(_onRefreshMethods);
  }

  /// 加载方法列表
  Future<void> _onLoadMethods(
    LoadMethods event,
    Emitter<MethodListState> emit,
  ) async {
    emit(const MethodListLoading());

    final result = await methodRepository.getMethods(
      category: event.category,
      difficulty: event.difficulty,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: event.page,
        hasMore: methods.length >= event.pageSize,
        currentCategory: event.category,
      )),
    );
  }

  /// 按分类筛选
  Future<void> _onFilterMethodsByCategory(
    FilterMethodsByCategory event,
    Emitter<MethodListState> emit,
  ) async {
    emit(const MethodListLoading());

    final result = await methodRepository.getMethods(
      category: event.category,
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: 1,
        hasMore: methods.length >= 20,
        currentCategory: event.category,
      )),
    );
  }

  /// 加载更多
  Future<void> _onLoadMoreMethods(
    LoadMoreMethods event,
    Emitter<MethodListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MethodListLoaded || !currentState.hasMore) {
      return;
    }

    emit(MethodListLoadingMore(
      methods: currentState.methods,
      currentPage: currentState.currentPage,
      currentCategory: currentState.currentCategory,
    ));

    final nextPage = currentState.currentPage + 1;
    final result = await methodRepository.getMethods(
      category: currentState.currentCategory,
      page: nextPage,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(currentState.copyWith()),
      (newMethods) {
        final allMethods = [...currentState.methods, ...newMethods];
        emit(MethodListLoaded(
          methods: allMethods,
          currentPage: nextPage,
          hasMore: newMethods.length >= 20,
          currentCategory: currentState.currentCategory,
        ));
      },
    );
  }

  /// 刷新列表
  Future<void> _onRefreshMethods(
    RefreshMethods event,
    Emitter<MethodListState> emit,
  ) async {
    final currentState = state;
    String? category;

    if (currentState is MethodListLoaded) {
      category = currentState.currentCategory;
    }

    final result = await methodRepository.getMethods(
      category: category,
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: 1,
        hasMore: methods.length >= 20,
        currentCategory: category,
      )),
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_list_state.dart';

/// 方法列表BLoC
class MethodListBloc extends Bloc<MethodListEvent, MethodListState> {
  final MethodRepository methodRepository;

  MethodListBloc({required this.methodRepository})
      : super(const MethodListInitial()) {
    on<LoadMethods>(_onLoadMethods);
    on<FilterMethodsByCategory>(_onFilterMethodsByCategory);
    on<LoadMoreMethods>(_onLoadMoreMethods);
    on<RefreshMethods>(_onRefreshMethods);
  }

  /// 加载方法列表
  Future<void> _onLoadMethods(
    LoadMethods event,
    Emitter<MethodListState> emit,
  ) async {
    emit(const MethodListLoading());

    final result = await methodRepository.getMethods(
      category: event.category,
      difficulty: event.difficulty,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: event.page,
        hasMore: methods.length >= event.pageSize,
        currentCategory: event.category,
      )),
    );
  }

  /// 按分类筛选
  Future<void> _onFilterMethodsByCategory(
    FilterMethodsByCategory event,
    Emitter<MethodListState> emit,
  ) async {
    emit(const MethodListLoading());

    final result = await methodRepository.getMethods(
      category: event.category,
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: 1,
        hasMore: methods.length >= 20,
        currentCategory: event.category,
      )),
    );
  }

  /// 加载更多
  Future<void> _onLoadMoreMethods(
    LoadMoreMethods event,
    Emitter<MethodListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MethodListLoaded || !currentState.hasMore) {
      return;
    }

    emit(MethodListLoadingMore(
      methods: currentState.methods,
      currentPage: currentState.currentPage,
      currentCategory: currentState.currentCategory,
    ));

    final nextPage = currentState.currentPage + 1;
    final result = await methodRepository.getMethods(
      category: currentState.currentCategory,
      page: nextPage,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(currentState.copyWith()),
      (newMethods) {
        final allMethods = [...currentState.methods, ...newMethods];
        emit(MethodListLoaded(
          methods: allMethods,
          currentPage: nextPage,
          hasMore: newMethods.length >= 20,
          currentCategory: currentState.currentCategory,
        ));
      },
    );
  }

  /// 刷新列表
  Future<void> _onRefreshMethods(
    RefreshMethods event,
    Emitter<MethodListState> emit,
  ) async {
    final currentState = state;
    String? category;

    if (currentState is MethodListLoaded) {
      category = currentState.currentCategory;
    }

    final result = await methodRepository.getMethods(
      category: category,
      page: 1,
      pageSize: 20,
    );

    result.fold(
      (failure) => emit(MethodListError(failure.message)),
      (methods) => emit(MethodListLoaded(
        methods: methods,
        currentPage: 1,
        hasMore: methods.length >= 20,
        currentCategory: category,
      )),
    );
  }
}

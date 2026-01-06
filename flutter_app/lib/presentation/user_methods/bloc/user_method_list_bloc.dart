import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/user_method_repository.dart';
import 'package:mental_app/presentation/user_methods/bloc/user_method_list_event.dart';
import 'package:mental_app/presentation/user_methods/bloc/user_method_list_state.dart';

/// 个人方法库列表 BLoC
class UserMethodListBloc
    extends Bloc<UserMethodListEvent, UserMethodListState> {
  final UserMethodRepository userMethodRepository;

  UserMethodListBloc({required this.userMethodRepository})
      : super(const UserMethodListInitial()) {
    on<LoadUserMethods>(_onLoadUserMethods);
    on<RefreshUserMethods>(_onRefreshUserMethods);
    on<FilterUserMethodsByCategory>(_onFilterUserMethodsByCategory);
    on<ToggleFavorite>(_onToggleFavorite);
    on<UpdateUserMethodGoal>(_onUpdateUserMethodGoal);
    on<DeleteUserMethod>(_onDeleteUserMethod);
  }

  /// 加载个人方法列表
  Future<void> _onLoadUserMethods(
    LoadUserMethods event,
    Emitter<UserMethodListState> emit,
  ) async {
    emit(const UserMethodListLoading());

    final result = await userMethodRepository.getUserMethods();

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (methods) => emit(UserMethodListLoaded(methods: methods)),
    );
  }

  /// 刷新个人方法列表
  Future<void> _onRefreshUserMethods(
    RefreshUserMethods event,
    Emitter<UserMethodListState> emit,
  ) async {
    final result = await userMethodRepository.getUserMethods();

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (methods) => emit(UserMethodListLoaded(methods: methods)),
    );
  }

  /// 按分类筛选
  Future<void> _onFilterUserMethodsByCategory(
    FilterUserMethodsByCategory event,
    Emitter<UserMethodListState> emit,
  ) async {
    emit(const UserMethodListLoading());

    final result = await userMethodRepository.getUserMethods();

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (methods) {
        // 如果没有选择分类，显示全部
        if (event.category == null) {
          emit(UserMethodListLoaded(
            methods: methods,
            currentCategory: null,
          ));
          return;
        }

        // 按分类筛选
        final filteredMethods = methods
            .where((method) => method.method.category == event.category)
            .toList();

        emit(UserMethodListLoaded(
          methods: filteredMethods,
          currentCategory: event.category,
        ));
      },
    );
  }

  /// 切换收藏状态
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<UserMethodListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserMethodListLoaded) return;

    // 查找要更新的方法
    final method = currentState.methods.firstWhere(
      (m) => m.id == event.userMethodId,
    );

    // 切换收藏状态
    final result = await userMethodRepository.updateUserMethod(
      id: event.userMethodId,
      isFavorite: !method.isFavorite,
    );

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (updatedMethod) {
        // 更新列表中的方法
        final updatedMethods = currentState.methods.map((m) {
          return m.id == event.userMethodId ? updatedMethod : m;
        }).toList();

        emit(UserMethodActionSuccess(
          message: updatedMethod.isFavorite ? '已添加到收藏' : '已取消收藏',
          methods: updatedMethods,
        ));

        // 立即切换回加载状态显示更新后的列表
        emit(UserMethodListLoaded(
          methods: updatedMethods,
          currentCategory: currentState.currentCategory,
        ));
      },
    );
  }

  /// 更新个人目标
  Future<void> _onUpdateUserMethodGoal(
    UpdateUserMethodGoal event,
    Emitter<UserMethodListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserMethodListLoaded) return;

    final result = await userMethodRepository.updateUserMethod(
      id: event.userMethodId,
      personalGoal: event.goal,
    );

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (updatedMethod) {
        // 更新列表中的方法
        final updatedMethods = currentState.methods.map((m) {
          return m.id == event.userMethodId ? updatedMethod : m;
        }).toList();

        emit(UserMethodActionSuccess(
          message: '目标更新成功',
          methods: updatedMethods,
        ));

        // 立即切换回加载状态显示更新后的列表
        emit(UserMethodListLoaded(
          methods: updatedMethods,
          currentCategory: currentState.currentCategory,
        ));
      },
    );
  }

  /// 删除个人方法
  Future<void> _onDeleteUserMethod(
    DeleteUserMethod event,
    Emitter<UserMethodListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserMethodListLoaded) return;

    final result =
        await userMethodRepository.deleteUserMethod(event.userMethodId);

    result.fold(
      (failure) => emit(UserMethodListError(failure.message)),
      (_) {
        // 从列表中移除方法
        final updatedMethods = currentState.methods
            .where((m) => m.id != event.userMethodId)
            .toList();

        emit(const UserMethodActionSuccess(
          message: '方法已删除',
          methods: [],
        ));

        // 立即切换回加载状态显示更新后的列表
        emit(UserMethodListLoaded(
          methods: updatedMethods,
          currentCategory: currentState.currentCategory,
        ));
      },
    );
  }
}

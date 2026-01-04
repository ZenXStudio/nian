import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';
import 'package:mental_app/domain/repositories/user_method_repository.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_state.dart';

/// 方法详情 BLoC
/// 
/// 负责处理方法详情相关的业务逻辑
class MethodDetailBloc extends Bloc<MethodDetailEvent, MethodDetailState> {
  final MethodRepository methodRepository;
  final UserMethodRepository userMethodRepository;

  MethodDetailBloc({
    required this.methodRepository,
    required this.userMethodRepository,
  }) : super(const MethodDetailInitial()) {
    on<LoadMethodDetail>(_onLoadMethodDetail);
    on<AddMethodToLibrary>(_onAddMethodToLibrary);
  }

  /// 处理加载方法详情事件
  Future<void> _onLoadMethodDetail(
    LoadMethodDetail event,
    Emitter<MethodDetailState> emit,
  ) async {
    emit(const MethodDetailLoading());

    final result = await methodRepository.getMethodById(event.methodId);

    result.fold(
      (failure) => emit(MethodDetailError(failure.message)),
      (method) => emit(MethodDetailLoaded(method)),
    );
  }

  /// 处理添加到个人方法库事件
  Future<void> _onAddMethodToLibrary(
    AddMethodToLibrary event,
    Emitter<MethodDetailState> emit,
  ) async {
    // 获取当前的方法信息
    final currentState = state;
    if (currentState is! MethodDetailLoaded) {
      emit(const MethodDetailError('无法添加到个人库，请先加载方法详情'));
      return;
    }

    emit(const MethodDetailLoading());

    final result = await userMethodRepository.addMethodToLibrary(
      methodId: event.methodId,
      personalGoal: event.personalGoal,
    );

    result.fold(
      (failure) {
        // 添加失败，恢复之前的状态
        emit(MethodDetailLoaded(currentState.method));
        emit(MethodDetailError(failure.message));
      },
      (userMethod) {
        // 添加成功
        emit(MethodAddedToLibrary(currentState.method));
        // 回到详情页状态，但显示成功消息
        emit(MethodDetailLoaded(currentState.method));
      },
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/method_repository.dart';
import 'package:mental_app/domain/repositories/user_method_repository.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_event.dart';
import 'package:mental_app/presentation/methods/bloc/method_detail_state.dart';

/// 方法详情 BLoC
/// 
/// 负责处理方法详情相关的业务逻辑
class MethodDetailBloc extends Bloc<MethodDetailEvent, MethodDetailState> {
  final MethodRepository methodRepository;
  final UserMethodRepository userMethodRepository;

  MethodDetailBloc({
    required this.methodRepository,
    required this.userMethodRepository,
  }) : super(const MethodDetailInitial()) {
    on<LoadMethodDetail>(_onLoadMethodDetail);
    on<AddMethodToLibrary>(_onAddMethodToLibrary);
  }

  /// 处理加载方法详情事件
  Future<void> _onLoadMethodDetail(
    LoadMethodDetail event,
    Emitter<MethodDetailState> emit,
  ) async {
    emit(const MethodDetailLoading());

    final result = await methodRepository.getMethodById(event.methodId);

    result.fold(
      (failure) => emit(MethodDetailError(failure.message)),
      (method) => emit(MethodDetailLoaded(method)),
    );
  }

  /// 处理添加到个人方法库事件
  Future<void> _onAddMethodToLibrary(
    AddMethodToLibrary event,
    Emitter<MethodDetailState> emit,
  ) async {
    // 获取当前的方法信息
    final currentState = state;
    if (currentState is! MethodDetailLoaded) {
      emit(const MethodDetailError('无法添加到个人库，请先加载方法详情'));
      return;
    }

    emit(const MethodDetailLoading());

    final result = await userMethodRepository.addMethodToLibrary(
      methodId: event.methodId,
      personalGoal: event.personalGoal,
    );

    result.fold(
      (failure) {
        // 添加失败，恢复之前的状态
        emit(MethodDetailLoaded(currentState.method));
        emit(MethodDetailError(failure.message));
      },
      (userMethod) {
        // 添加成功
        emit(MethodAddedToLibrary(currentState.method));
        // 回到详情页状态，但显示成功消息
        emit(MethodDetailLoaded(currentState.method));
      },
    );
  }
}

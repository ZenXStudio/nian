import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/domain/repositories/user_method_repository.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_state.dart';

/// 练习记录BLoC
class PracticeRecordBloc extends Bloc<PracticeRecordEvent, PracticeRecordState> {
  final PracticeRepository practiceRepository;
  final UserMethodRepository? userMethodRepository;

  PracticeRecordBloc({
    required this.practiceRepository,
    this.userMethodRepository,
  }) : super(const PracticeRecordInitial()) {
    on<LoadUserMethodsForPractice>(_onLoadUserMethods);
    on<CreatePracticeRecord>(_onCreatePracticeRecord);
  }

  /// 加载用户方法列表
  Future<void> _onLoadUserMethods(
    LoadUserMethodsForPractice event,
    Emitter<PracticeRecordState> emit,
  ) async {
    emit(const PracticeRecordLoading());

    if (userMethodRepository == null) {
      emit(const PracticeRecordError('用户方法仓库未配置'));
      return;
    }

    final result = await userMethodRepository!.getUserMethods();

    result.fold(
      (failure) => emit(PracticeRecordError(failure.message)),
      (methods) => emit(UserMethodsLoaded(methods)),
    );
  }

  /// 创建练习记录
  Future<void> _onCreatePracticeRecord(
    CreatePracticeRecord event,
    Emitter<PracticeRecordState> emit,
  ) async {
    emit(const PracticeRecordSaving());

    final result = await practiceRepository.recordPractice(
      methodId: event.userMethodId,
      durationMinutes: event.durationMinutes,
      moodBefore: event.moodBefore,
      moodAfter: event.moodAfter,
      notes: event.note,
    );

    result.fold(
      (failure) => emit(PracticeRecordError(failure.message)),
      (record) => emit(PracticeRecordSaved(record)),
    );
  }
}

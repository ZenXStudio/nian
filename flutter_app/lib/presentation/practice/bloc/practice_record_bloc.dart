import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_state.dart';

/// 练习记录BLoC
class PracticeRecordBloc extends Bloc<PracticeRecordEvent, PracticeRecordState> {
  final PracticeRepository practiceRepository;

  PracticeRecordBloc({required this.practiceRepository})
      : super(const PracticeRecordInitial()) {
    on<CreatePracticeRecord>(_onCreatePracticeRecord);
  }

  /// 创建练习记录
  Future<void> _onCreatePracticeRecord(
    CreatePracticeRecord event,
    Emitter<PracticeRecordState> emit,
  ) async {
    emit(const PracticeRecordSaving());

    final result = await practiceRepository.recordPractice(
      methodId: event.methodId,
      durationMinutes: event.durationMinutes,
      moodBefore: event.moodBefore,
      moodAfter: event.moodAfter,
      practiceDate: event.practiceDate,
      note: event.note,
    );

    result.fold(
      (failure) => emit(PracticeRecordError(failure.message)),
      (record) => emit(PracticeRecordSaved(record)),
    );
  }
}

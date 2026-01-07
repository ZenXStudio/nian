import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/presentation/practice/bloc/practice_stats_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_stats_state.dart';

/// 练习统计BLoC
class PracticeStatsBloc extends Bloc<PracticeStatsEvent, PracticeStatsState> {
  final PracticeRepository practiceRepository;

  PracticeStatsBloc({required this.practiceRepository})
      : super(const PracticeStatsInitial()) {
    on<LoadPracticeStats>(_onLoadPracticeStats);
    on<ChangeTimeRange>(_onChangeTimeRange);
  }

  /// 加载练习统计
  Future<void> _onLoadPracticeStats(
    LoadPracticeStats event,
    Emitter<PracticeStatsState> emit,
  ) async {
    emit(const PracticeStatsLoading());

    final result = await practiceRepository.getPracticeStatistics(
      startDate: DateTime.now().subtract(Duration(days: event.days)),
    );

    result.fold(
      (failure) => emit(PracticeStatsError(failure.message)),
      (stats) => emit(PracticeStatsLoaded(
        stats: stats,
        days: event.days,
      )),
    );
  }

  /// 切换时间范围
  Future<void> _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<PracticeStatsState> emit,
  ) async {
    emit(const PracticeStatsLoading());

    final result = await practiceRepository.getPracticeStatistics(
      startDate: DateTime.now().subtract(Duration(days: event.days)),
    );

    result.fold(
      (failure) => emit(PracticeStatsError(failure.message)),
      (stats) => emit(PracticeStatsLoaded(
        stats: stats,
        days: event.days,
      )),
    );
  }
}

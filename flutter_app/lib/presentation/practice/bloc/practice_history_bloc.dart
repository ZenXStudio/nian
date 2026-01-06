import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/presentation/practice/bloc/practice_history_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_history_state.dart';

/// 练习历史BLoC
class PracticeHistoryBloc extends Bloc<PracticeHistoryEvent, PracticeHistoryState> {
  final PracticeRepository practiceRepository;

  PracticeHistoryBloc({required this.practiceRepository})
      : super(const PracticeHistoryInitial()) {
    on<LoadPracticeHistory>(_onLoadPracticeHistory);
    on<FilterByTimeRange>(_onFilterByTimeRange);
    on<RefreshHistory>(_onRefreshHistory);
  }

  /// 加载练习历史
  Future<void> _onLoadPracticeHistory(
    LoadPracticeHistory event,
    Emitter<PracticeHistoryState> emit,
  ) async {
    emit(const PracticeHistoryLoading());

    final result = await practiceRepository.getPracticeHistory(
      methodId: event.methodId,
    );

    result.fold(
      (failure) => emit(PracticeHistoryError(failure.message)),
      (records) {
        // 计算统计数据
        final totalCount = records.length;
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final weekCount = records.where((r) => r.practiceDate.isAfter(weekAgo)).length;

        emit(PracticeHistoryLoaded(
          records: records,
          totalCount: totalCount,
          weekCount: weekCount,
        ));
      },
    );
  }

  /// 按时间范围筛选
  Future<void> _onFilterByTimeRange(
    FilterByTimeRange event,
    Emitter<PracticeHistoryState> emit,
  ) async {
    emit(const PracticeHistoryLoading());

    final result = await practiceRepository.getPracticeHistory();

    result.fold(
      (failure) => emit(PracticeHistoryError(failure.message)),
      (allRecords) {
        List<PracticeRecord> filteredRecords;
        final now = DateTime.now();

        switch (event.timeRange) {
          case 'week':
            final weekAgo = now.subtract(const Duration(days: 7));
            filteredRecords = allRecords.where((r) => r.practiceDate.isAfter(weekAgo)).toList();
            break;
          case 'month':
            final monthAgo = now.subtract(const Duration(days: 30));
            filteredRecords = allRecords.where((r) => r.practiceDate.isAfter(monthAgo)).toList();
            break;
          default:
            filteredRecords = allRecords;
        }

        final totalCount = allRecords.length;
        final weekAgo = now.subtract(const Duration(days: 7));
        final weekCount = allRecords.where((r) => r.practiceDate.isAfter(weekAgo)).length;

        emit(PracticeHistoryLoaded(
          records: filteredRecords,
          totalCount: totalCount,
          weekCount: weekCount,
        ));
      },
    );
  }

  /// 刷新历史记录
  Future<void> _onRefreshHistory(
    RefreshHistory event,
    Emitter<PracticeHistoryState> emit,
  ) async {
    final result = await practiceRepository.getPracticeHistory();

    result.fold(
      (failure) => emit(PracticeHistoryError(failure.message)),
      (records) {
        final totalCount = records.length;
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final weekCount = records.where((r) => r.practiceDate.isAfter(weekAgo)).length;

        emit(PracticeHistoryLoaded(
          records: records,
          totalCount: totalCount,
          weekCount: weekCount,
        ));
      },
    );
  }
}

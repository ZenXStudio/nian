import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/practice_record.dart';

/// 练习历史状态基类
abstract class PracticeHistoryState extends Equatable {
  const PracticeHistoryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PracticeHistoryInitial extends PracticeHistoryState {
  const PracticeHistoryInitial();
}

/// 加载中
class PracticeHistoryLoading extends PracticeHistoryState {
  const PracticeHistoryLoading();
}

/// 加载成功
class PracticeHistoryLoaded extends PracticeHistoryState {
  final List<PracticeRecord> records;
  final int totalCount;
  final int weekCount;

  const PracticeHistoryLoaded({
    required this.records,
    required this.totalCount,
    required this.weekCount,
  });

  @override
  List<Object?> get props => [records, totalCount, weekCount];
}

/// 加载失败
class PracticeHistoryError extends PracticeHistoryState {
  final String message;

  const PracticeHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

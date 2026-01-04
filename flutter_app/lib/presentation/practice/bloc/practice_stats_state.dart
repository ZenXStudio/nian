import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/practice_stats.dart';

/// 练习统计状态基类
abstract class PracticeStatsState extends Equatable {
  const PracticeStatsState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PracticeStatsInitial extends PracticeStatsState {
  const PracticeStatsInitial();
}

/// 加载中
class PracticeStatsLoading extends PracticeStatsState {
  const PracticeStatsLoading();
}

/// 加载成功
class PracticeStatsLoaded extends PracticeStatsState {
  final PracticeStats stats;
  final int days;

  const PracticeStatsLoaded({
    required this.stats,
    required this.days,
  });

  @override
  List<Object?> get props => [stats, days];
}

/// 加载失败
class PracticeStatsError extends PracticeStatsState {
  final String message;

  const PracticeStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

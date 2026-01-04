import 'package:equatable/equatable.dart';

/// 练习统计事件基类
abstract class PracticeStatsEvent extends Equatable {
  const PracticeStatsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载练习统计
class LoadPracticeStats extends PracticeStatsEvent {
  final int days; // 7, 30, 90

  const LoadPracticeStats({this.days = 7});

  @override
  List<Object?> get props => [days];
}

/// 切换时间范围
class ChangeTimeRange extends PracticeStatsEvent {
  final int days;

  const ChangeTimeRange(this.days);

  @override
  List<Object?> get props => [days];
}

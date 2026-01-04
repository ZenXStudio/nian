import 'package:equatable/equatable.dart';

/// 练习历史事件基类
abstract class PracticeHistoryEvent extends Equatable {
  const PracticeHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// 加载练习历史
class LoadPracticeHistory extends PracticeHistoryEvent {
  final String? timeRange; // 'week', 'month', 'all'
  final int? methodId;

  const LoadPracticeHistory({
    this.timeRange,
    this.methodId,
  });

  @override
  List<Object?> get props => [timeRange, methodId];
}

/// 按时间范围筛选
class FilterByTimeRange extends PracticeHistoryEvent {
  final String timeRange;

  const FilterByTimeRange(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}

/// 刷新历史记录
class RefreshHistory extends PracticeHistoryEvent {
  const RefreshHistory();
}

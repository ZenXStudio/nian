import 'package:equatable/equatable.dart';

/// 练习统计实体
///
/// 表示用户的练习统计数据
class PracticeStats extends Equatable {
  /// 总练习次数
  final int totalCount;
  
  /// 总练习时长（分钟）
  final int totalMinutes;
  
  /// 平均心理状态改善
  final double averageMoodImprovement;
  
  /// 当前连续天数
  final int currentStreak;
  
  /// 最长连续天数
  final int longestStreak;

  const PracticeStats({
    required this.totalCount,
    required this.totalMinutes,
    required this.averageMoodImprovement,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// 平均每次练习时长
  double get averageDuration =>
      totalCount > 0 ? totalMinutes / totalCount : 0.0;

  /// 平均改善（别名）
  double get averageImprovement => averageMoodImprovement;

  @override
  List<Object?> get props => [
        totalCount,
        totalMinutes,
        averageMoodImprovement,
        currentStreak,
        longestStreak,
      ];

  @override
  String toString() =>
      'PracticeStats(totalCount: $totalCount, totalMinutes: $totalMinutes)';
}

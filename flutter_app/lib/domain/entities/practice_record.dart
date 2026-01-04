import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/method.dart';

/// 练习记录实体
///
/// 表示用户的练习记录
class PracticeRecord extends Equatable {
  /// 记录ID
  final int id;
  
  /// 用户ID
  final int userId;
  
  /// 方法ID
  final int methodId;
  
  /// 关联的方法信息（可选）
  final Method? method;
  
  /// 练习时长（分钟）
  final int durationMinutes;
  
  /// 练习前心理状态（1-10）
  final int moodBefore;
  
  /// 练习后心理状态（1-10）
  final int moodAfter;
  
  /// 练习笔记
  final String? notes;
  
  /// 练习时间
  final DateTime practicedAt;

  const PracticeRecord({
    required this.id,
    required this.userId,
    required this.methodId,
    this.method,
    required this.durationMinutes,
    required this.moodBefore,
    required this.moodAfter,
    this.notes,
    required this.practicedAt,
  });

  /// 心理状态改善程度
  int get moodImprovement => moodAfter - moodBefore;

  @override
  List<Object?> get props => [
        id,
        userId,
        methodId,
        method,
        durationMinutes,
        moodBefore,
        moodAfter,
        notes,
        practicedAt,
      ];

  @override
  String toString() =>
      'PracticeRecord(id: $id, methodId: $methodId, moodImprovement: $moodImprovement)';
}

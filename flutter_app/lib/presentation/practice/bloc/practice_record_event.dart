import 'package:equatable/equatable.dart';

/// 练习记录事件基类
abstract class PracticeRecordEvent extends Equatable {
  const PracticeRecordEvent();

  @override
  List<Object?> get props => [];
}

/// 加载用户方法列表（用于创建练习记录）
class LoadUserMethodsForPractice extends PracticeRecordEvent {
  const LoadUserMethodsForPractice();
}

/// 创建练习记录
class CreatePracticeRecord extends PracticeRecordEvent {
  final int userMethodId;
  final int durationMinutes;
  final int moodBefore;
  final int moodAfter;
  final DateTime practiceDate;
  final String? note;

  const CreatePracticeRecord({
    required this.userMethodId,
    required this.durationMinutes,
    required this.moodBefore,
    required this.moodAfter,
    required this.practiceDate,
    this.note,
  });

  @override
  List<Object?> get props => [
        userMethodId,
        durationMinutes,
        moodBefore,
        moodAfter,
        practiceDate,
        note,
      ];
}

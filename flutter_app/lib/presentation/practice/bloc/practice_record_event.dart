import 'package:equatable/equatable.dart';

/// 练习记录事件基类
abstract class PracticeRecordEvent extends Equatable {
  const PracticeRecordEvent();

  @override
  List<Object?> get props => [];
}

/// 创建练习记录
class CreatePracticeRecord extends PracticeRecordEvent {
  final int methodId;
  final int durationMinutes;
  final int moodBefore;
  final int moodAfter;
  final DateTime practiceDate;
  final String? note;

  const CreatePracticeRecord({
    required this.methodId,
    required this.durationMinutes,
    required this.moodBefore,
    required this.moodAfter,
    required this.practiceDate,
    this.note,
  });

  @override
  List<Object?> get props => [
        methodId,
        durationMinutes,
        moodBefore,
        moodAfter,
        practiceDate,
        note,
      ];
}

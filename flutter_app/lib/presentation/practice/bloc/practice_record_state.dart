import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/practice_record.dart';

/// 练习记录状态基类
abstract class PracticeRecordState extends Equatable {
  const PracticeRecordState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PracticeRecordInitial extends PracticeRecordState {
  const PracticeRecordInitial();
}

/// 保存中
class PracticeRecordSaving extends PracticeRecordState {
  const PracticeRecordSaving();
}

/// 保存成功
class PracticeRecordSaved extends PracticeRecordState {
  final PracticeRecord record;

  const PracticeRecordSaved(this.record);

  @override
  List<Object?> get props => [record];
}

/// 保存失败
class PracticeRecordError extends PracticeRecordState {
  final String message;

  const PracticeRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

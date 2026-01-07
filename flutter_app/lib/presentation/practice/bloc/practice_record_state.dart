import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/practice_record.dart';
import 'package:mental_app/domain/entities/user_method.dart';

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

/// 加载中
class PracticeRecordLoading extends PracticeRecordState {
  const PracticeRecordLoading();
}

/// 用户方法已加载
class UserMethodsLoaded extends PracticeRecordState {
  final List<UserMethod> userMethods;

  const UserMethodsLoaded(this.userMethods);

  @override
  List<Object?> get props => [userMethods];
}

/// 创建中
class PracticeRecordCreating extends PracticeRecordState {
  const PracticeRecordCreating();
}

/// 创建成功
class PracticeRecordCreated extends PracticeRecordState {
  final PracticeRecord record;

  const PracticeRecordCreated(this.record);

  @override
  List<Object?> get props => [record];
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

/// 错误状态
class PracticeRecordError extends PracticeRecordState {
  final String message;

  const PracticeRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

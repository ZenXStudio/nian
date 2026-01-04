import 'package:equatable/equatable.dart';

/// 方法详情事件基类
abstract class MethodDetailEvent extends Equatable {
  const MethodDetailEvent();

  @override
  List<Object?> get props => [];
}

/// 加载方法详情
class LoadMethodDetail extends MethodDetailEvent {
  final int methodId;

  const LoadMethodDetail(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

/// 添加到个人方法库
class AddMethodToLibrary extends MethodDetailEvent {
  final int methodId;
  final String? personalGoal;

  const AddMethodToLibrary({
    required this.methodId,
    this.personalGoal,
  });

  @override
  List<Object?> get props => [methodId, personalGoal];
}

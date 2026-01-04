import 'package:equatable/equatable.dart';
import 'package:mental_app/domain/entities/user.dart';

/// 个人资料状态基类
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// 加载中
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// 加载成功
class ProfileLoaded extends ProfileState {
  final User user;
  final int totalPracticeDays;
  final int totalPracticeCount;
  final int consecutiveDays;

  const ProfileLoaded({
    required this.user,
    required this.totalPracticeDays,
    required this.totalPracticeCount,
    required this.consecutiveDays,
  });

  @override
  List<Object?> get props => [
        user,
        totalPracticeDays,
        totalPracticeCount,
        consecutiveDays,
      ];
}

/// 加载失败
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 更新成功
class ProfileUpdated extends ProfileState {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// 数据导出成功
class DataExported extends ProfileState {
  final String filePath;

  const DataExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

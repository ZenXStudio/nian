import 'package:equatable/equatable.dart';

/// 个人资料事件基类
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// 加载个人资料
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// 更新昵称
class UpdateNickname extends ProfileEvent {
  final String nickname;

  const UpdateNickname(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

/// 切换主题
class ChangeTheme extends ProfileEvent {
  final String themeMode; // 'light', 'dark', 'system'

  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// 导出数据
class ExportData extends ProfileEvent {
  const ExportData();
}

/// 退出登录
class Logout extends ProfileEvent {
  const Logout();
}

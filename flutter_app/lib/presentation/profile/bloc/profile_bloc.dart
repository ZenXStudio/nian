import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/auth_repository.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/presentation/profile/bloc/profile_event.dart';
import 'package:mental_app/presentation/profile/bloc/profile_state.dart';

/// 个人资料BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final PracticeRepository practiceRepository;

  ProfileBloc({
    required this.authRepository,
    required this.practiceRepository,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateNickname>(_onUpdateNickname);
    on<ChangeTheme>(_onChangeTheme);
    on<ExportData>(_onExportData);
    on<Logout>(_onLogout);
  }

  /// 加载个人资料
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    // 获取当前用户信息
    final userResult = await authRepository.getCurrentUser();

    await userResult.fold(
      (failure) async => emit(ProfileError(failure.message)),
      (user) async {
        // 获取练习统计
        final statsResult = await practiceRepository.getPracticeStatistics(
          days: 365, // 获取全年数据
        );

        statsResult.fold(
          (failure) => emit(ProfileError(failure.message)),
          (stats) {
            // 计算统计数据
            final totalPracticeDays = stats.totalCount > 0 ? stats.totalCount : 0;
            final totalPracticeCount = stats.totalCount;
            final consecutiveDays = 7; // TODO: 从stats中获取

            emit(ProfileLoaded(
              user: user,
              totalPracticeDays: totalPracticeDays,
              totalPracticeCount: totalPracticeCount,
              consecutiveDays: consecutiveDays,
            ));
          },
        );
      },
    );
  }

  /// 更新昵称
  Future<void> _onUpdateNickname(
    UpdateNickname event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    // TODO: 调用API更新昵称
    // 目前只更新本地状态
    emit(ProfileUpdated(currentState.user));
  }

  /// 切换主题
  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ProfileState> emit,
  ) async {
    // TODO: 保存主题设置到本地存储
  }

  /// 导出数据
  Future<void> _onExportData(
    ExportData event,
    Emitter<ProfileState> emit,
  ) async {
    // TODO: 实现数据导出功能
    emit(const DataExported('/path/to/export.json'));
  }

  /// 退出登录
  Future<void> _onLogout(
    Logout event,
    Emitter<ProfileState> emit,
  ) async {
    await authRepository.logout();
    emit(const ProfileInitial());
  }
}

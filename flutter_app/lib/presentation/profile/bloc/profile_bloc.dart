import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/domain/repositories/auth_repository.dart';
import 'package:mental_app/domain/repositories/practice_repository.dart';
import 'package:mental_app/presentation/profile/bloc/profile_event.dart';
import 'package:mental_app/presentation/profile/bloc/profile_state.dart';
import 'package:mental_app/core/storage/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
            final consecutiveDays = _calculateConsecutiveDays(totalPracticeCount);
            
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

    emit(const ProfileLoading());

    // 调用API更新昵称
    final result = await authRepository.updateProfile(
      nickname: event.nickname,
    );

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (updatedUser) {
        emit(ProfileUpdated(updatedUser));
        // 立即重新加载资料，显示更新后的数据
        emit(ProfileLoaded(
          user: updatedUser,
          totalPracticeDays: currentState.totalPracticeDays,
          totalPracticeCount: currentState.totalPracticeCount,
          consecutiveDays: currentState.consecutiveDays,
        ));
      },
    );
  }

  /// 切换主题
  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ProfileState> emit,
  ) async {
    // 保存主题设置到本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', event.themeMode);
  }

  /// 导出数据
  Future<void> _onExportData(
    ExportData event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // 获取当前用户信息
      final userResult = await authRepository.getCurrentUser();
      if (userResult.isLeft()) {
        emit(const ProfileError('获取用户信息失败'));
        return;
      }

      // 获取练习记录（最近365天）
      final recordsResult = await practiceRepository.getPracticeHistory(
        days: 365,
      );

      final exportData = {
        'export_time': DateTime.now().toIso8601String(),
        'user': userResult.getOrElse(() => throw Exception()),
        'practice_records':
            recordsResult.getOrElse(() => []).map((r) => r.toString()).toList(),
        'statistics': await practiceRepository.getPracticeStatistics(days: 365),
      };

      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/practice_data_${DateTime.now().millisecondsSinceEpoch}.json');

      // 写入文件
      await file.writeAsString(json.encode(exportData));

      emit(DataExported(file.path));
    } catch (e) {
      emit(ProfileError('数据导出失败：${e.toString()}'));
    }
  }

  /// 计算连续练习天数（简化实现）
  int _calculateConsecutiveDays(int totalCount) {
    // 简化逻辑：根据总次数估算
    // 实际应该从练习记录中计算连续天数
    if (totalCount == 0) return 0;
    if (totalCount < 7) return totalCount;
    return 7; // 默认返回7天
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

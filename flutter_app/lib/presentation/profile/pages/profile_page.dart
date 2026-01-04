import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:mental_app/presentation/auth/bloc/auth_event.dart';

/// 个人资料页
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(context),
          
          const SizedBox(height: 16),
          
          // 练习概览
          _buildPracticeOverview(context),
          
          const SizedBox(height: 16),
          
          // 个人信息设置组
          _buildSettingsGroup(
            context,
            '个人信息',
            [
              _buildSettingsItem(
                context,
                Icons.person_outline,
                '修改昵称',
                onTap: () {
                  // TODO: 显示修改昵称对话框
                  _showEditNicknameDialog(context);
                },
              ),
              _buildSettingsItem(
                context,
                Icons.lock_outline,
                '修改密码',
                onTap: () {
                  Navigator.pushNamed(context, '/change-password');
                },
              ),
            ],
          ),
          
          // 应用设置组
          _buildSettingsGroup(
            context,
            '应用设置',
            [
              _buildSettingsItem(
                context,
                Icons.dark_mode_outlined,
                '主题设置',
                trailing: '跟随系统',
                onTap: () {
                  // TODO: 显示主题选择
                },
              ),
              _buildSettingsItem(
                context,
                Icons.notifications_outlined,
                '通知设置',
                onTap: () {
                  // TODO: 跳转到通知设置
                },
              ),
            ],
          ),
          
          // 数据管理组
          _buildSettingsGroup(
            context,
            '数据管理',
            [
              _buildSettingsItem(
                context,
                Icons.download_outlined,
                '导出数据',
                onTap: () {
                  // TODO: 导出数据
                  _showExportDialog(context);
                },
              ),
              _buildSettingsItem(
                context,
                Icons.cleaning_services_outlined,
                '清除缓存',
                trailing: '12.5 MB',
                onTap: () {
                  // TODO: 清除缓存
                },
              ),
            ],
          ),
          
          // 关于组
          _buildSettingsGroup(
            context,
            '关于',
            [
              _buildSettingsItem(
                context,
                Icons.info_outline,
                '关于应用',
                trailing: 'v1.0.0',
                onTap: () {
                  // TODO: 显示关于页面
                },
              ),
              _buildSettingsItem(
                context,
                Icons.privacy_tip_outlined,
                '隐私政策',
                onTap: () {
                  // TODO: 显示隐私政策
                },
              ),
              _buildSettingsItem(
                context,
                Icons.description_outlined,
                '用户协议',
                onTap: () {
                  // TODO: 显示用户协议
                },
              ),
            ],
          ),
          
          // 退出登录按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('退出登录'),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              'U',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '用户昵称',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '注册时间: 2024-01-01',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建练习概览
  Widget _buildPracticeOverview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '练习概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('总天数', '28', Icons.calendar_today),
              _buildOverviewItem('总次数', '156', Icons.check_circle),
              _buildOverviewItem('连续', '7天', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建概览项
  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建设置组
  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建设置项
  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// 显示修改昵称对话框
  void _showEditNicknameDialog(BuildContext context) {
    final controller = TextEditingController(text: '用户昵称');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '昵称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 保存昵称
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示导出数据对话框
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('将导出您的所有练习记录和个人设置数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 执行导出
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导出成功')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // 触发退出登录事件
              context.read<AuthBloc>().add(const LogoutRequested());
              // 跳转到登录页
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

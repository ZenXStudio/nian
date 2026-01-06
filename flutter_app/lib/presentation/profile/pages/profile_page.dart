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
                onTap: () => _showEditNicknameDialog(context),
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
                onTap: () => _showThemeSelector(context),
              ),
              _buildSettingsItem(
                context,
                Icons.notifications_outlined,
                '通知设置',
                onTap: () => _showNotificationSettings(context),
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
                onTap: () => _showExportDialog(context),
              ),
              _buildSettingsItem(
                context,
                Icons.cleaning_services_outlined,
                '清除缓存',
                trailing: '12.5 MB',
                onTap: () => _showClearCacheDialog(context),
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
                onTap: () => _showAboutDialog(context),
              ),
              _buildSettingsItem(
                context,
                Icons.privacy_tip_outlined,
                '隐私政策',
                onTap: () => _showPrivacyPolicy(context),
              ),
              _buildSettingsItem(
                context,
                Icons.description_outlined,
                '用户协议',
                onTap: () => _showUserAgreement(context),
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
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('昵称修改成功')),
                );
              }
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导出成功，已保存至下载目录')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  /// 显示主题选择对话框
  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择主题'),
        children: [
          RadioListTile<String>(
            title: const Text('跟随系统'),
            value: 'system',
            groupValue: 'system',
            onChanged: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已切换到跟随系统')),
              );
            },
          ),
          RadioListTile<String>(
            title: const Text('浅色模式'),
            value: 'light',
            groupValue: 'system',
            onChanged: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已切换到浅色模式')),
              );
            },
          ),
          RadioListTile<String>(
            title: const Text('深色模式'),
            value: 'dark',
            groupValue: 'system',
            onChanged: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已切换到深色模式')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 显示通知设置对话框
  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('练习提醒'),
              subtitle: const Text('每日定时提醒练习'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('新方法推送'),
              subtitle: const Text('推送适合您的新方法'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('系统通知'),
              subtitle: const Text('接收系统公告消息'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示清除缓存对话框
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除缓存吗？这将释放 12.5 MB 存储空间。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  /// 显示关于应用对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '心理自助',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.self_improvement, color: Colors.white, size: 32),
      ),
      applicationLegalese: '© 2024 心理自助团队',
      children: [
        const SizedBox(height: 16),
        const Text(
          '心理自助是一款专注于心理健康的应用，提供多种科学有效的自助方法，帮助用户缓解压力、改善情绪、提升睡眠质量。',
        ),
      ],
    );
  }

  /// 显示隐私政策
  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '隐私政策',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '''隐私政策

更新日期：2024年1月1日
生效日期：2024年1月1日

一、信息收集
我们收集的信息类型包括：
1. 账户信息：注册时的邮箱、昵称等
2. 使用数据：练习记录、偏好设置等
3. 设备信息：设备型号、操作系统版本等

二、信息使用
我们使用收集的信息用于：
1. 提供和改进服务
2. 个性化您的体验
3. 发送通知和更新

三、信息保护
我们采用行业标准的安全措施保护您的信息，包括加密存储和传输。

四、信息共享
我们不会出售或出租您的个人信息给第三方。

五、联系我们
如有任何问题，请联系：support@mentalapp.com''',
                  style: TextStyle(height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示用户协议
  void _showUserAgreement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '用户协议',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '''用户服务协议

更新日期：2024年1月1日

欢迎使用心理自助应用！

一、服务条款
1. 本应用提供心理健康自助服务，仅供参考，不构成医疗建议
2. 用户应年满16周岁，未成年人需在监护人指导下使用
3. 用户应妥善保管账户信息

二、用户行为规范
1. 不得发布违法、有害信息
2. 不得干扰应用正常运行
3. 不得侵犯他人合法权益

三、知识产权
1. 应用内容版权归开发者所有
2. 用户生成内容由用户负责

四、免责声明
1. 本应用不提供专业心理咨询或医疗服务
2. 如有严重心理问题，请寻求专业帮助

五、协议变更
我们保留修改本协议的权利，修改后的协议将在应用内公布。

六、联系方式
如有问题请联系：support@mentalapp.com''',
                  style: TextStyle(height: 1.6),
                ),
              ),
            ),
          ],
        ),
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

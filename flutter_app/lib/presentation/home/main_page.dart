import 'package:flutter/material.dart';
import 'package:mental_app/presentation/methods/pages/method_discover_page.dart';
import 'package:mental_app/presentation/user_methods/pages/user_method_list_page.dart';
import 'package:mental_app/presentation/practice/pages/practice_history_page.dart';
import 'package:mental_app/presentation/profile/pages/profile_page.dart';

/// 主页面 - 带底部导航栏
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  DateTime? _lastPressedAt;

  // 页面列表
  final List<Widget> _pages = const [
    MethodDiscoverPage(),
    UserMethodListPage(),
    PracticeHistoryPage(),
    ProfilePage(),
  ];

  // 导航项配置
  final List<BottomNavigationBarItem> _navigationItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books),
      label: '我的方法',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: '练习',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: _navigationItems,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  /// 底部导航栏点击事件
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// 返回键处理 - 双击退出应用
  Future<bool> _onWillPop() async {
    // 如果不在首页，返回首页
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    // 在首页，双击退出
    final now = DateTime.now();
    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      // 第一次按返回键
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('再按一次退出应用'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    // 第二次按返回键，退出应用
    return true;
  }
}

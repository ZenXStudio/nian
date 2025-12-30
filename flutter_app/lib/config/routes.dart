import 'package:flutter/material.dart';
import 'package:mental_app/screens/splash_screen.dart';
import 'package:mental_app/screens/auth/login_screen.dart';
import 'package:mental_app/screens/auth/register_screen.dart';
import 'package:mental_app/screens/home/home_screen.dart';
import 'package:mental_app/screens/method/method_list_screen.dart';
import 'package:mental_app/screens/method/method_detail_screen.dart';
import 'package:mental_app/screens/practice/practice_screen.dart';
import 'package:mental_app/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String methodList = '/methods';
  static const String methodDetail = '/method-detail';
  static const String practice = '/practice';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    methodList: (context) => const MethodListScreen(),
    methodDetail: (context) => const MethodDetailScreen(),
    practice: (context) => const PracticeScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
import 'package:flutter/material.dart';
import 'package:mental_app/screens/splash_screen.dart';
import 'package:mental_app/screens/auth/login_screen.dart';
import 'package:mental_app/screens/auth/register_screen.dart';
import 'package:mental_app/screens/home/home_screen.dart';
import 'package:mental_app/screens/method/method_list_screen.dart';
import 'package:mental_app/screens/method/method_detail_screen.dart';
import 'package:mental_app/screens/practice/practice_screen.dart';
import 'package:mental_app/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String methodList = '/methods';
  static const String methodDetail = '/method-detail';
  static const String practice = '/practice';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    methodList: (context) => const MethodListScreen(),
    methodDetail: (context) => const MethodDetailScreen(),
    practice: (context) => const PracticeScreen(),
    profile: (context) => const ProfileScreen(),
  };
}

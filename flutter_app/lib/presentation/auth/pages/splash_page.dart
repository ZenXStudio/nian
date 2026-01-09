import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:mental_app/presentation/auth/bloc/auth_state.dart';

/// 启动页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  void _navigate(BuildContext context, AuthState state) {
    if (_hasNavigated) return;
    
    if (state is Authenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (state is Unauthenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) => _navigate(context, state),
      builder: (context, state) {
        // 初始状态时也检查一次
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigate(context, state);
        });
        
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  '心理自助应用',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}

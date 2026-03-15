import 'package:flutter/material.dart';
import 'package:votera/features/authentication/presentation/widgets/login_section.dart';
import 'package:votera/features/authentication/presentation/widgets/register_section.dart';

/// The authentication page handles both login and registration.
/// Users switch between the two via a tab-like toggle at the top.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isLogin
              ? LoginSection(
                  key: const ValueKey('login'),
                  onSwitchToRegister: _toggleMode,
                )
              : RegisterSection(
                  key: const ValueKey('register'),
                  onSwitchToLogin: _toggleMode,
                ),
        ),
      ),
    );
  }
}

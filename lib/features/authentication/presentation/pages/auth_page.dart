import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/widgets/login_section.dart';
import 'package:votera/features/authentication/presentation/widgets/register_section.dart';

/// The authentication page handles both login and registration.
/// Users switch between the two via a tab-like toggle at the top.
/// On desktop, displays a two-panel layout with branding on the left.
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
    final formContent = AnimatedSwitcher(
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
    );

    if (AppBreakpoints.isDesktop(context)) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // Branding panel
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.how_to_vote,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Votera',
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Discover, vote, and celebrate\ninnovative projects.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Form panel
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppBreakpoints.formPanelMax,
                    ),
                    child: SingleChildScrollView(
                      padding: AppSpacing.pagePadding,
                      child: formContent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile / Tablet: centered form
    return Scaffold(
      body: SafeArea(
        child: CenteredContent(
          maxWidth: AppBreakpoints.formPanelMax,
          child: formContent,
        ),
      ),
    );
  }
}

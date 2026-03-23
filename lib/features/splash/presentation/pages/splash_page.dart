import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Splash screen shown at app launch.
/// Checks for saved auth tokens and navigates to the appropriate screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    unawaited(_controller.forward());

    unawaited(_checkAuth());
  }

  Future<void> _checkAuth() async {
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkAuthStatus();

    // Brief delay so the splash is visible before navigating.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (authCubit.state is AuthAuthenticated) {
      // Load the profile so role-based navigation is ready before home renders.
      if (mounted) {
        await context.read<ProfileCubit>().loadProfile();
      }
      if (mounted) context.go('/home');
    } else {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'V',
                    style: AppTypography.h1.copyWith(
                      fontSize: 48,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // App name
              Text(
                l10n.appTitle,
                style: AppTypography.h1.copyWith(
                  fontSize: 36,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appMotto,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

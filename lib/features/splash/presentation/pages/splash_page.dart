import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
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
    // checkAuthStatus() is now called centrally from _AuthStateListener in
    // app.dart on the first frame, so we only need to wait for the auth state
    // to settle and then navigate.
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.go('/home');
    } else {
      context.go('/onboarding');
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
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
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
                      fontSize: 48.sp,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // App name
              Text(
                l10n.appTitle,
                style: AppTypography.h1.copyWith(
                  fontSize: 36.sp,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10n.appMotto,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 60.h),
              SizedBox(
                width: 28.r,
                height: 28.r,
                child: const CircularProgressIndicator(
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

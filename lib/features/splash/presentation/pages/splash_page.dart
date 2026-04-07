import 'dart:async';
import 'dart:math' as math;

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

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Logo: scale + fade in over 700ms.
  late final AnimationController _logoController;

  // Text (title + motto): fade + slide up, starts 300ms after logo.
  late final AnimationController _textController;

  // Three loading dots: repeating pulse.
  late final AnimationController _dotsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Start logo immediately, then stagger text and dots.
    unawaited(_logoController.forward());
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) unawaited(_textController.forward());
    });
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) unawaited(_dotsController.repeat());
    });

    unawaited(_checkAuth());
  }

  Future<void> _checkAuth() async {
    // checkAuthStatus() is called centrally from _AuthStateListener in
    // app.dart on the first frame, so we only need to wait for the auth
    // state to settle before navigating.
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
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Decorative background glow — large blurred circle centered
          // slightly above the middle to give depth to the background.
          Positioned.fill(
            child: CustomPaint(painter: _GlowPainter(primaryColor: context.colors.primary)),
          ),

          // Main content centered on screen.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                SizedBox(height: AppSpacing.xl),
                _buildText(l10n),
              ],
            ),
          ),

          // Three pulsing dots pinned to the bottom.
          Positioned(
            bottom: 52.h,
            left: 0,
            right: 0,
            child: _buildLoadingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoFade,
        child: Container(
          width: 96.r,
          height: 96.r,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: [
              // Soft glow around the icon using the active theme's primary color.
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.35),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: 12,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'V',
              style: AppTypography.h1.copyWith(
                fontSize: 46.sp,
                color: context.colors.textOnPrimary,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(AppLocalizations l10n) {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textFade,
        child: Column(
          children: [
            Text(
              l10n.appTitle,
              style: AppTypography.h1.copyWith(
                fontSize: 34.sp,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              l10n.appMotto,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textHint,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot pulses with a phase offset so they ripple one by one.
            final phase = i / 3.0;
            final value = _dotsController.value;
            // Compute a 0→1→0 pulse for this dot based on its phase offset.
            final t = ((value + (1 - phase)) % 1.0);
            final opacity = (math.sin(t * math.pi)).clamp(0.2, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.r),
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Paints two overlapping soft radial glows to break the flatness of the
/// background and draw the eye toward the center.
/// Receives [primaryColor] from the widget so it adapts to light/dark theme.
class _GlowPainter extends CustomPainter {
  const _GlowPainter({required this.primaryColor});

  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);

    // Outer large glow.
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.07),
          Colors.transparent,
        ],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.75));

    canvas.drawCircle(center, size.width * 0.75, outerPaint);

    // Inner tighter glow.
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.09),
          Colors.transparent,
        ],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.38));

    canvas.drawCircle(center, size.width * 0.38, innerPaint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor;
}
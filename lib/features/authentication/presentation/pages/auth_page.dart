import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/widgets/login_section.dart';
import 'package:votera/features/authentication/presentation/widgets/register_section.dart';

/// The authentication page handles both login and registration.
/// Mobile: gradient header with branding, rounded white card for the form.
/// Desktop: two-panel layout with gradient branding on the left.
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
      return _buildDesktopLayout(formContent);
    }

    return _buildMobileLayout(formContent);
  }

  // -- Section: Desktop two-panel layout --
  Widget _buildDesktopLayout(Widget formContent) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(child: _buildBrandingPanel()),
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

  // -- Section: Desktop branding panel --
  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.how_to_vote,
              size: 96,
              color: Colors.white,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Votera',
              style: AppTypography.h1.copyWith(
                color: Colors.white,
                fontSize: 40,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Discover, vote, and celebrate\ninnovative projects.',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // -- Section: Mobile layout with gradient header --
  Widget _buildMobileLayout(Widget formContent) {
    return Scaffold(
      body: Column(
        children: [
          _buildGradientHeader(),
          Expanded(
            child: _buildFormCard(formContent),
          ),
        ],
      ),
    );
  }

  // Gradient header with app branding for mobile
  Widget _buildGradientHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.how_to_vote,
            size: 56,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Votera',
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Discover, vote, and celebrate',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // White card with rounded top corners that overlaps the gradient
  Widget _buildFormCard(Widget formContent) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: CenteredContent(
          maxWidth: AppBreakpoints.formPanelMax,
          child: formContent,
        ),
      ),
    );
  }
}

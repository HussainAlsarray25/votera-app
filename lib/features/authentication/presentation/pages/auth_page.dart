import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/authentication/presentation/widgets/login_section.dart';
import 'package:votera/features/authentication/presentation/widgets/register_section.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// The authentication page handles both login and registration.
/// Mobile: plain scaffold with the form filling the screen.
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

    final body = BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<ProfileCubit>().loadProfile();
          context.go('/home');
        } else if (state is AuthOtpRequired) {
          context.go('/otp', extra: {
            'identifier': state.identifier,
            'isRegistration': false,
          });
        } else if (state is AuthRegistrationOtpRequired) {
          context.go('/otp', extra: {
            'identifier': state.identifier,
            'isRegistration': true,
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: AppBreakpoints.isDesktop(context)
          ? _buildDesktopLayout(formContent)
          : _buildMobileLayout(formContent),
    );

    return body;
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: context.colors.primaryGradient,
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
              l10n.appTitle,
              style: AppTypography.h1.copyWith(
                color: Colors.white,
                fontSize: 40,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.appTagline,
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

  // -- Section: Mobile layout --
  Widget _buildMobileLayout(Widget formContent) {
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

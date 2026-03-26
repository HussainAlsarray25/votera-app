import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/authentication/presentation/widgets/telegram_login_button.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// The login form section of the authentication page.
/// Contains the header, email/password fields, and submit button.
class LoginSection extends StatefulWidget {
  const LoginSection({required this.onSwitchToRegister, super.key});

  final VoidCallback onSwitchToRegister;

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _buildHeader(l10n),
            const SizedBox(height: AppSpacing.xxl),
            _buildEmailField(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(l10n),
            _buildForgotPassword(l10n),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(l10n),
            const SizedBox(height: AppSpacing.md),
            const TelegramLoginButton(),
            const SizedBox(height: AppSpacing.lg),
            _buildSwitchLink(l10n),
          ],
        ),
      ),
    );
  }

  // -- Section: Welcome header --
  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.welcomeBack,
          style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.signInToVote,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Email input --
  Widget _buildEmailField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.email,
      controller: _emailController,
      hint: l10n.enterEmail,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.emailRequired;
        if (!value.contains('@')) return l10n.emailInvalid;
        return null;
      },
    );
  }

  // -- Section: Password input --
  Widget _buildPasswordField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.password,
      controller: _passwordController,
      hint: l10n.enterPassword,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: context.colors.textHint,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.passwordRequired;
        if (value.length < 6) return l10n.passwordTooShort;
        return null;
      },
    );
  }

  // -- Section: Forgot password link --
  Widget _buildForgotPassword(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          ),
          child: Text(
            l10n.forgotPassword,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // -- Section: Submit button --
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GradientButton(
          text: isLoading ? l10n.signingIn : l10n.signIn,
          onPressed: isLoading ? null : _handleLogin,
        );
      },
    );
  }

  // -- Section: Switch to register link --
  Widget _buildSwitchLink(AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: widget.onSwitchToRegister,
        child: Text.rich(
          TextSpan(
            text: l10n.noAccount,
            style: AppTypography.bodyMedium,
            children: [
              TextSpan(
                text: l10n.signUp,
                style: AppTypography.labelMedium
                    .copyWith(color: context.colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            identifier: _emailController.text.trim(),
            secret: _passwordController.text,
          );
    }
  }
}

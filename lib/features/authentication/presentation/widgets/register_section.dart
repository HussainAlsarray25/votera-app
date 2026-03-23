import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/authentication/presentation/widgets/telegram_login_button.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// The registration form section of the authentication page.
/// Collects name, email, and password from new users.
class RegisterSection extends StatefulWidget {
  const RegisterSection({required this.onSwitchToLogin, super.key});

  final VoidCallback onSwitchToLogin;

  @override
  State<RegisterSection> createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(height: AppSpacing.xxl),
            _buildHeader(l10n),
            const SizedBox(height: AppSpacing.xxl),
            _buildNameField(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildIdentifierField(l10n),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(l10n),
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

  // -- Section: Header --
  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.createAccount,
          style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.joinExhibition,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Name input --
  Widget _buildNameField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.fullName,
      controller: _nameController,
      hint: l10n.enterFullName,
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.nameRequired;
        return null;
      },
    );
  }

  // -- Section: Identifier input --
  Widget _buildIdentifierField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.identifier,
      controller: _identifierController,
      hint: l10n.enterIdentifier,
      prefixIcon: Icons.alternate_email_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.identifierRequired;
        return null;
      },
    );
  }

  // -- Section: Password input --
  Widget _buildPasswordField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.password,
      controller: _passwordController,
      hint: l10n.createPassword,
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

  // -- Section: Submit button --
  Widget _buildSubmitButton(AppLocalizations l10n) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GradientButton(
          text: isLoading ? l10n.creatingAccount : l10n.createAccount,
          onPressed: isLoading ? null : _handleRegister,
        );
      },
    );
  }

  // -- Section: Switch to login link --
  Widget _buildSwitchLink(AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: widget.onSwitchToLogin,
        child: Text.rich(
          TextSpan(
            text: l10n.alreadyHaveAccount,
            style: AppTypography.bodyMedium,
            children: [
              TextSpan(
                text: l10n.signIn,
                style: AppTypography.labelMedium
                    .copyWith(color: context.colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().register(
            fullName: _nameController.text.trim(),
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}

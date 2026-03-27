import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Shown after the user receives the password-reset email.
/// The user pastes the hex token from the email and sets a new password.
/// On success, navigates back to the login screen.
class ConfirmResetPage extends StatefulWidget {
  const ConfirmResetPage({required this.email, super.key});

  // Pre-filled for display only — the API does not need the email here.
  final String email;

  @override
  State<ConfirmResetPage> createState() => _ConfirmResetPageState();
}

class _ConfirmResetPageState extends State<ConfirmResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().confirmPasswordReset(
            token: _tokenController.text.trim(),
            newPassword: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          l10n.confirmResetTitle,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.passwordResetSuccess),
                backgroundColor: context.colors.success,
              ),
            );
            // Return to login — replace the entire stack so back is not possible.
            context.go('/auth');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.colors.error,
              ),
            );
          }
        },
        child: FormCardShell(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.xl),
                  _buildHeader(l10n),
                  SizedBox(height: AppSpacing.xxl),
                  _buildTokenField(l10n),
                  SizedBox(height: AppSpacing.md),
                  _buildPasswordField(l10n),
                  SizedBox(height: AppSpacing.md),
                  _buildConfirmPasswordField(l10n),
                  SizedBox(height: AppSpacing.xl),
                  _buildSubmitButton(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Title and description --
  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.confirmResetTitle,
          style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.confirmResetDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          widget.email,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Token input (paste from email) --
  Widget _buildTokenField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.resetToken,
      controller: _tokenController,
      hint: l10n.pasteToken,
      prefixIcon: Icons.key_outlined,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return l10n.tokenRequired;
        return null;
      },
    );
  }

  // -- Section: New password input --
  Widget _buildPasswordField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.newPasswordLabel,
      controller: _passwordController,
      hint: l10n.enterNewPassword,
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
        if (value == null || value.isEmpty) return l10n.newPasswordRequired;
        if (value.length < 6) return l10n.passwordTooShort;
        return null;
      },
    );
  }

  // -- Section: Confirm password input --
  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return AppTextField(
      label: l10n.confirmPasswordLabel,
      controller: _confirmController,
      hint: l10n.confirmPasswordHint,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscureConfirm,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
          color: context.colors.textHint,
          size: 20,
        ),
        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.newPasswordRequired;
        if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
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
          text: isLoading ? l10n.resetting : l10n.setNewPassword,
          onPressed: isLoading ? null : _handleSubmit,
        );
      },
    );
  }
}
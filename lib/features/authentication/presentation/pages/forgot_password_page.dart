import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Allows the user to request a password-reset email.
/// The backend emails a hex token the user will paste on the next screen.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().requestPasswordReset(
            email: _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          AppLocalizations.of(context)!.forgotPasswordTitle,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            // Navigate to the confirm-reset screen so the user can paste
            // the token from their email and set a new password.
            context.pushReplacement(
              '/confirm-reset',
              extra: {'email': _emailController.text.trim()},
            );
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
          child: _buildForm(),
        ),
      ),
    );
  }

  // -- Section: Email form --
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.xl),
          _buildHeader(),
          SizedBox(height: AppSpacing.xxl),
          _buildEmailField(),
          SizedBox(height: AppSpacing.xl),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // -- Section: Title and description --
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.resetPassword,
          style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.resetPasswordDesc,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Email input --
  Widget _buildEmailField() {
    final l10n = AppLocalizations.of(context)!;
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

  // -- Section: Submit button --
  Widget _buildSubmitButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final isLoading = state is AuthLoading;
        return GradientButton(
          text: isLoading ? l10n.sending : l10n.sendResetLink,
          onPressed: isLoading ? null : _handleSubmit,
        );
      },
    );
  }
}

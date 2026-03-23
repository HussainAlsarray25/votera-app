import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/authentication/presentation/widgets/telegram_login_button.dart';
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
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(height: AppSpacing.xxl),
            _buildHeader(),
            const SizedBox(height: AppSpacing.xxl),
            _buildNameField(),
            const SizedBox(height: AppSpacing.md),
            _buildIdentifierField(),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
            const SizedBox(height: AppSpacing.md),
            const TelegramLoginButton(),
            const SizedBox(height: AppSpacing.lg),
            _buildSwitchLink(),
          ],
        ),
      ),
    );
  }

  // -- Section: Header --
  Widget _buildHeader() {
    return Column(
      children: [
        Text('Create Account', style: AppTypography.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Join the exhibition and start voting',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Name input --
  Widget _buildNameField() {
    return AppTextField(
      label: 'Full Name',
      controller: _nameController,
      hint: 'Enter your full name',
      prefixIcon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Name is required';
        return null;
      },
    );
  }

  // -- Section: Identifier input --
  Widget _buildIdentifierField() {
    return AppTextField(
      label: 'Identifier',
      controller: _identifierController,
      hint: 'Enter your email or username',
      prefixIcon: Icons.alternate_email_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Identifier is required';
        return null;
      },
    );
  }

  // -- Section: Password input --
  Widget _buildPasswordField() {
    return AppTextField(
      label: 'Password',
      controller: _passwordController,
      hint: 'Create a password',
      prefixIcon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // -- Section: Submit button --
  Widget _buildSubmitButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return GradientButton(
          text: isLoading ? 'Creating Account...' : 'Create Account',
          onPressed: isLoading ? null : _handleRegister,
        );
      },
    );
  }

  // -- Section: Switch to login link --
  Widget _buildSwitchLink() {
    return Center(
      child: TextButton(
        onPressed: widget.onSwitchToLogin,
        child: Text.rich(
          TextSpan(
            text: 'Already have an account? ',
            style: AppTypography.bodyMedium,
            children: [
              TextSpan(
                text: 'Sign In',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.primary),
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

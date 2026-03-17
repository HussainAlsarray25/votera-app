import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
            const SizedBox(height: AppSpacing.lg),
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildNameField(),
            const SizedBox(height: AppSpacing.md),
            _buildEmailField(),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
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

  // -- Section: Email input --
  Widget _buildEmailField() {
    return AppTextField(
      label: 'Email',
      controller: _emailController,
      hint: 'Enter your email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        if (!value.contains('@')) return 'Enter a valid email';
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
    return GradientButton(
      text: 'Create Account',
      onPressed: _handleRegister,
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
      context.go('/user-info');
    }
  }
}

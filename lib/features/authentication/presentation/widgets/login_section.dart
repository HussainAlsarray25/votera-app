import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
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
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
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

  // -- Section: Welcome header --
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome Back', style: AppTypography.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in to vote for your favorite projects',
          style: AppTypography.bodyMedium,
        ),
      ],
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
      hint: 'Enter your password',
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
      text: 'Sign In',
      onPressed: _handleLogin,
    );
  }

  // -- Section: Switch to register link --
  Widget _buildSwitchLink() {
    return Center(
      child: GestureDetector(
        onTap: widget.onSwitchToRegister,
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: AppTypography.bodyMedium,
            children: [
              TextSpan(
                text: 'Sign Up',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go('/home');
    }
  }
}

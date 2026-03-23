import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Two-step institutional email verification page.
/// Step 1: Enter email → OTP sent.
/// Step 2: Enter 6-digit OTP → participant role granted.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const _otpLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  // Tracks the email submitted in step 1 so step 2 can reuse it.
  String _submittedEmail = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill email from profile if available.
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      final email = profileState.profile.email;
      if (email != null) _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpCode.length == _otpLength;

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      _submittedEmail = _emailController.text.trim();
      context.read<FormsCubit>().sendEmailOtp(_submittedEmail);
    }
  }

  void _handleVerifyOtp() {
    if (!_isOtpComplete) return;
    context.read<FormsCubit>().confirmEmailOtp(_submittedEmail, _otpCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          'Institutional Email',
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<FormsCubit, FormsState>(
        listener: (context, state) {
          if (state is FormsEmailVerified) {
            // Force-refresh clears the stale cached role before fetching,
            // so the Teams tab and other role-gated UI update immediately.
            context.read<ProfileCubit>().forceRefresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account verified! Participant role granted.'),
                backgroundColor: context.colors.success,
              ),
            );
            context.go('/profile');
          } else if (state is FormsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.colors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: BlocBuilder<FormsCubit, FormsState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state is FormsEmailOtpSent
                      ? _buildOtpStep(state.email)
                      : _buildEmailStep(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // -- Step 1: Email input --
  Widget _buildEmailStep() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('email-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Enter Your Institutional Email',
            style: AppTypography.h1.copyWith(
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We will send a 6-digit verification code to your university email.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: 'Institutional Email',
            controller: _emailController,
            hint: 'your.name@university.edu',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<FormsCubit, FormsState>(
            builder: (context, state) {
              final isLoading = state is FormsLoading;
              return GradientButton(
                text: isLoading ? 'Sending...' : 'Send OTP',
                onPressed: isLoading ? null : _handleSendOtp,
              );
            },
          ),
        ],
      ),
    );
  }

  // -- Step 2: OTP input --
  Widget _buildOtpStep(String email) {
    return Column(
      key: const ValueKey('otp-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Enter Verification Code',
          style: AppTypography.h1.copyWith(
            color: context.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We sent a 6-digit code to',
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildOtpBoxes(),
        const SizedBox(height: AppSpacing.xxl),
        BlocBuilder<FormsCubit, FormsState>(
          builder: (context, state) {
            final isLoading = state is FormsLoading;
            return GradientButton(
              text: isLoading ? 'Verifying...' : 'Verify',
              onPressed: (isLoading || !_isOtpComplete) ? null : _handleVerifyOtp,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            width: 48,
            height: 56,
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
                height: 1,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: context.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onOtpDigitChanged(index, value),
              onSubmitted: (_) {
                if (_isOtpComplete) _handleVerifyOtp();
              },
            ),
          ),
        );
      }),
    );
  }
}

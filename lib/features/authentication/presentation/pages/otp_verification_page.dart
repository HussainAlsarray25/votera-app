import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Shown after registration (to verify the account OTP) or after login
/// when the server requires OTP verification.
///
/// [isRegistration] controls which cubit method is called on submit:
///   - true  → verifyRegistrationOtp (POST /auth/register/verify)
///   - false → verifyOtp             (POST /auth/login/verify)
class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    required this.identifier,
    required this.isRegistration,
    super.key,
  });

  final String identifier;
  final bool isRegistration;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const _otpLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpCode.length == _otpLength;

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      // Move focus to the next box after entering a digit.
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move focus back when a digit is deleted.
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _handleSubmit() {
    if (!_isComplete) return;
    final cubit = context.read<AuthCubit>();
    if (widget.isRegistration) {
      cubit.verifyRegistrationOtp(
        identifier: widget.identifier,
        code: _otpCode,
      );
    } else {
      cubit.verifyOtp(
        identifier: widget.identifier,
        code: _otpCode,
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
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<ProfileCubit>().loadProfile();
            context.go('/home');
          } else if (state is AuthError) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xl),
                _buildHeader(),
                SizedBox(height: AppSpacing.xxl),
                _buildOtpBoxes(),
                SizedBox(height: AppSpacing.xxl),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Section: Title and description --
  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.isRegistration
        ? l10n.verifyYourAccount
        : l10n.enterVerificationCode;

    return Column(
      children: [
        Text(
          title,
          style: AppTypography.h1.copyWith(color: context.colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.codeSentTo,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          widget.identifier,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -- Section: Six individual digit input boxes --
  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.r),
          child: SizedBox(
            width: 48.r,
            height: 56.r,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 22.sp,
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
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onDigitChanged(index, value),
              onSubmitted: (_) {
                if (_isComplete) _handleSubmit();
              },
            ),
          ),
        );
      }),
    );
  }

  // -- Section: Submit button --
  Widget _buildSubmitButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final isLoading = state is AuthLoading;
        return GradientButton(
          text: isLoading ? l10n.verifying : l10n.verify,
          onPressed: (isLoading || !_isComplete) ? null : _handleSubmit,
        );
      },
    );
  }
}

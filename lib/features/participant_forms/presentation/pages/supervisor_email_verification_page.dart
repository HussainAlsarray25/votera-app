import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/app_text_field.dart';
import 'package:votera/shared/widgets/gradient_button.dart';

/// Two-step supervisor email verification page.
/// Step 1: Enter supervisor email → OTP sent.
/// Step 2: Enter 6-digit OTP → supervisor role granted.
class SupervisorEmailVerificationPage extends StatefulWidget {
  const SupervisorEmailVerificationPage({super.key});

  @override
  State<SupervisorEmailVerificationPage> createState() =>
      _SupervisorEmailVerificationPageState();
}

class _SupervisorEmailVerificationPageState
    extends State<SupervisorEmailVerificationPage> {
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
      context.read<FormsCubit>().sendSupervisorEmailOtp(_submittedEmail);
    }
  }

  void _handleVerifyOtp() {
    if (!_isOtpComplete) return;
    context
        .read<FormsCubit>()
        .confirmSupervisorEmailOtp(_submittedEmail, _otpCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: context.colors.textPrimary),
        title: Text(
          AppLocalizations.of(context)!.supervisorEmail,
          style: AppTypography.labelLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<FormsCubit, FormsState>(
        listener: (context, state) {
          if (state is FormsSupervisorEmailVerified) {
            // Force-refresh clears the stale cached role before fetching,
            // so the profile and all role-gated UI update immediately.
            context.read<ProfileCubit>().forceRefresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    AppLocalizations.of(context)!.supervisorAccountVerified),
                backgroundColor: context.colors.primary,
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
          child: CenteredContent(
            maxWidth: AppBreakpoints.formPanelMax,
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: BlocBuilder<FormsCubit, FormsState>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state is FormsSupEmailOtpSent
                        ? _buildOtpStep(state.email)
                        : _buildEmailStep(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -- Step 1: Email input --
  Widget _buildEmailStep() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('supervisor-email-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.xl),
          Text(
            l10n.enterSupervisorEmail,
            style: AppTypography.h1.copyWith(
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            l10n.supervisorEmailDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: l10n.supervisorEmail,
            controller: _emailController,
            hint: l10n.supervisorEmailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.emailRequired;
              if (!value.contains('@')) return l10n.emailInvalid;
              // The supervisor domain is @uokufa.edu.iq, but student emails use
              // the @student.uokufa.edu.iq subdomain — reject those here.
              if (value.toLowerCase().endsWith('@student.uokufa.edu.iq')) {
                return l10n.teacherEmailNotStudent;
              }
              if (!value.toLowerCase().endsWith('@uokufa.edu.iq')) {
                return l10n.teacherEmailDomainError;
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.xl),
          BlocBuilder<FormsCubit, FormsState>(
            builder: (context, state) {
              final isLoading = state is FormsLoading;
              return GradientButton(
                text: isLoading ? l10n.sending : l10n.sendOtp,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('supervisor-otp-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.xl),
        Text(
          l10n.enterVerificationCode,
          style: AppTypography.h1.copyWith(
            color: context.colors.textPrimary,
          ),
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
          email,
          style: AppTypography.labelMedium.copyWith(
            color: context.colors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxl),
        _buildOtpBoxes(),
        SizedBox(height: AppSpacing.xxl),
        BlocBuilder<FormsCubit, FormsState>(
          builder: (context, state) {
            final isLoading = state is FormsLoading;
            return GradientButton(
              text: isLoading ? l10n.verifying : l10n.verify,
              onPressed:
                  (isLoading || !_isOtpComplete) ? null : _handleVerifyOtp,
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
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: SizedBox(
            width: 48.w,
            height: 56.h,
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
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

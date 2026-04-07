import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/onboarding/presentation/pages/onboarding_page.dart';

/// A single onboarding slide with a decorative accent line, title,
/// and description. Minimal and text-focused for a clean aesthetic.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.data, super.key});

  final OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAccentLine(context),
          SizedBox(height: AppSpacing.lg),
          _buildTitle(context),
          SizedBox(height: AppSpacing.md),
          _buildDescription(context),
        ],
      ),
    );
  }

  // Small gradient bar as a decorative accent above the title
  Widget _buildAccentLine(BuildContext context) {
    return Container(
      width: 48.r,
      height: 4.r,
      decoration: BoxDecoration(
        gradient: context.colors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      data.title,
      style: AppTypography.h1.copyWith(
        fontSize: 30.sp,
        letterSpacing: -0.5,
        color: context.colors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      data.description,
      style: AppTypography.bodyMedium.copyWith(
        height: 1.7,
        color: context.colors.textHint,
      ),
      textAlign: TextAlign.center,
    );
  }
}

import 'package:flutter/material.dart';
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
          _buildAccentLine(),
          const SizedBox(height: AppSpacing.lg),
          _buildTitle(),
          const SizedBox(height: AppSpacing.md),
          _buildDescription(),
        ],
      ),
    );
  }

  // Small gradient bar as a decorative accent above the title
  Widget _buildAccentLine() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      data.title,
      style: AppTypography.h1.copyWith(
        fontSize: 30,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      data.description,
      style: AppTypography.bodyMedium.copyWith(
        height: 1.7,
        color: AppColors.textHint,
      ),
      textAlign: TextAlign.center,
    );
  }
}

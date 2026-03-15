import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/onboarding/presentation/pages/onboarding_page.dart';

/// A single onboarding slide with a large icon, title, and description.
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
          _buildIcon(),
          const SizedBox(height: AppSpacing.xl),
          _buildTitle(),
          const SizedBox(height: AppSpacing.md),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Icon(data.icon, size: 56, color: Colors.white),
    );
  }

  Widget _buildTitle() {
    return Text(
      data.title,
      style: AppTypography.h2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      data.description,
      style: AppTypography.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}

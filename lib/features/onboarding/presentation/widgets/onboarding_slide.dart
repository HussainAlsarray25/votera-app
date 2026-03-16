import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/onboarding/presentation/pages/onboarding_page.dart';

/// A single onboarding slide with a large icon, title, and description.
/// Icon container scales up on tablet/desktop for better visual balance.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.data, super.key});

  final OnboardingData data;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final containerSize = isMobile ? 120.0 : 160.0;
    final iconSize = isMobile ? 56.0 : 72.0;

    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(containerSize, iconSize),
          const SizedBox(height: AppSpacing.xl),
          _buildTitle(),
          const SizedBox(height: AppSpacing.md),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildIcon(double containerSize, double iconSize) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Icon(data.icon, size: iconSize, color: Colors.white),
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

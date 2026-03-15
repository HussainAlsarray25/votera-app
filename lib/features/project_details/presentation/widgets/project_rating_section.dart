import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';

/// Allows the user to rate the project and shows the average rating.
class ProjectRatingSection extends StatelessWidget {
  const ProjectRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _buildAverageRating(),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          _buildUserRating(),
        ],
      ),
    );
  }

  // -- Section: Average community rating --
  Widget _buildAverageRating() {
    return Row(
      children: [
        // Large rating number
        Text(
          '4.5',
          style: AppTypography.h1.copyWith(
            fontSize: 40,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnimatedStarRating(
                rating: 4,
                size: 22,
                isInteractive: false,
              ),
              const SizedBox(height: 4),
              Text('Based on 48 votes', style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  // -- Section: Interactive user rating --
  Widget _buildUserRating() {
    return Column(
      children: [
        Text('Rate this project', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStarRating(
          size: 36,
          onRatingChanged: (rating) {
            // Will dispatch to Cubit
          },
        ),
      ],
    );
  }
}

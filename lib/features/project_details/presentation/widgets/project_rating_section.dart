import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';

/// Allows the user to rate the project and shows the average rating.
/// Reads from and dispatches to RatingsCubit.
class ProjectRatingSection extends StatelessWidget {
  const ProjectRatingSection({required this.projectId, super.key});

  final String projectId;

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
          _buildAverageRating(context),
          const Divider(height: AppSpacing.xl, color: AppColors.divider),
          _buildUserRating(context),
        ],
      ),
    );
  }

  // -- Section: Average community rating --
  Widget _buildAverageRating(BuildContext context) {
    return BlocBuilder<RatingsCubit, RatingsState>(
      builder: (context, state) {
        final averageScore =
            state is RatingSummaryLoaded ? state.summary.averageScore : 0.0;
        final totalRatings =
            state is RatingSummaryLoaded ? state.summary.totalRatings : 0;
        final isLoading = state is RatingsLoading;

        if (isLoading) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        return Row(
          children: [
            Text(
              averageScore.toStringAsFixed(1),
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
                  AnimatedStarRating(
                    rating: averageScore.round(),
                    size: 22,
                    isInteractive: false,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on $totalRatings ratings',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // -- Section: Interactive user rating --
  Widget _buildUserRating(BuildContext context) {
    return Column(
      children: [
        Text('Rate this project', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        AnimatedStarRating(
          size: 36,
          onRatingChanged: (rating) {
            context
                .read<RatingsCubit>()
                .rate(projectId: projectId, score: rating);
          },
        ),
      ],
    );
  }
}

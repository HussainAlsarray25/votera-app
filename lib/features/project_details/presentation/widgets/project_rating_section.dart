import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/ratings/presentation/cubit/ratings_cubit.dart';
import 'package:votera/l10n/gen/app_localizations.dart';
import 'package:votera/shared/widgets/animated_star_rating.dart';

/// Displays the community average rating and lets the user submit their own.
/// Reads from and dispatches to [RatingsCubit].
class ProjectRatingSection extends StatelessWidget {
  const ProjectRatingSection({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Column(
        children: [
          _buildAverageRating(context),
          Divider(height: 1, color: context.colors.divider),
          _buildUserRating(context),
        ],
      ),
    );
  }

  // -- Top half: community average --
  Widget _buildAverageRating(BuildContext context) {
    return BlocBuilder<RatingsCubit, RatingsState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final isLoading = state is RatingsLoading;
        final averageScore =
            state is RatingSummaryLoaded ? state.summary.averageScore : 0.0;
        final totalRatings =
            state is RatingSummaryLoaded ? state.summary.totalRatings : 0;

        return Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              // Large score number with gradient background
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          averageScore.toStringAsFixed(1),
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.communityRating,
                      style: AppTypography.labelLarge.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedStarRating(
                      rating: isLoading ? 0 : averageScore.round(),
                      size: 20,
                      isInteractive: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading
                          ? l10n.loading
                          : l10n.ratingCount(totalRatings),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -- Bottom half: user's own rating picker --
  Widget _buildUserRating(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rateThisProject,
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tapStarToRate,
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedStarRating(
            size: 32,
            onRatingChanged: (rating) {
              context
                  .read<RatingsCubit>()
                  .rate(projectId: projectId, score: rating);
            },
          ),
        ],
      ),
    );
  }
}

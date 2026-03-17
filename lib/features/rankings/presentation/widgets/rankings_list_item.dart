import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';

/// A single ranked project row showing rank number, avatar, name, team,
/// vote count, and a chevron indicator.
class RankingsListItem extends StatelessWidget {
  const RankingsListItem({
    required this.project,
    required this.rank,
    super.key,
  });

  final DemoProject project;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        CategoryStyles.podiumGradient(project.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRankNumber(),
          const SizedBox(width: 12),
          _buildAvatar(gradientColors),
          const SizedBox(width: 14),
          Expanded(child: _buildInfo()),
          _buildVoteCount(),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildRankNumber() {
    return SizedBox(
      width: 28,
      child: Text(
        '$rank',
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildAvatar(List<Color> colors) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(project.emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'By ${project.teamName}',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVoteCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${project.votes}',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'VOTES',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// A horizontal list of projects the current user has voted for.
class ProfileVotedProjectsSection extends StatelessWidget {
  const ProfileVotedProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.pagePadding,
          child: Text('Your Votes', style: AppTypography.h3),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, index) => _buildVotedCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildVotedCard(int index) {
    final names = ['Smart Campus', 'AI Tutor', 'EcoTrack', 'MedAssist'];
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.accent,
    ];

    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors[index].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors[index].withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code, color: colors[index], size: 22),
          const Spacer(),
          Text(
            names[index],
            style: AppTypography.labelMedium.copyWith(color: colors[index]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text('Voted', style: AppTypography.caption),
        ],
      ),
    );
  }
}

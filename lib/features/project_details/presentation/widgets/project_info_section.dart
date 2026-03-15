import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/shared/widgets/verified_badge.dart';

/// Displays the project title, author, category, and description.
class ProjectInfoSection extends StatelessWidget {
  const ProjectInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndCategory(),
        const SizedBox(height: AppSpacing.md),
        _buildAuthorRow(),
        const SizedBox(height: AppSpacing.lg),
        _buildDescription(),
      ],
    );
  }

  Widget _buildTitleAndCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            'Mobile App',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Smart Campus Navigator', style: AppTypography.h2),
      ],
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            'A',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Prof. Ahmed Ali', style: AppTypography.labelMedium),
                const SizedBox(width: 4),
                const VerifiedBadge(),
              ],
            ),
            Text('Computer Science Dept.', style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this Project', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'An innovative mobile application that helps students and visitors '
          'navigate the university campus using augmented reality and '
          'real-time indoor positioning. Features include classroom finder, '
          'event schedules, and accessibility routes.',
          style: AppTypography.bodyMedium.copyWith(height: 1.7,),
        ),
      ],
    );
  }
}

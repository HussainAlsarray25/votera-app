import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Displays a row of stat cards: votes cast, projects rated, and rank.
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          _buildStatCard(
            'Votes Cast',
            '12',
            Icons.how_to_vote,
            AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildStatCard('Rated', '8', Icons.star, AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          _buildStatCard(
            'Comments',
            '5',
            Icons.chat_bubble,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTypography.h3.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

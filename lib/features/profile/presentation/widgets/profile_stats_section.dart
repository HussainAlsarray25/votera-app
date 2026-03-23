import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Displays a row of stat cards: votes cast, projects rated, and comments.
/// Shows placeholder values until a stats endpoint is available.
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          _buildStatCard(
            context,
            'Votes Cast',
            '\u2014',
            Icons.how_to_vote,
            context.colors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildStatCard(
            context,
            'Rated',
            '\u2014',
            Icons.star,
            context.colors.accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildStatCard(
            context,
            'Comments',
            '\u2014',
            Icons.chat_bubble,
            context.colors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
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
              style: AppTypography.caption.copyWith(
                color: context.colors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

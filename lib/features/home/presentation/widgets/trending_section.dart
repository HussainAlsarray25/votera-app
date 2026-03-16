import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';

/// Horizontal scrollable section showing the top trending projects.
/// Each card has a gradient overlay with the project name and vote count.
/// Cards scale up on wider screens for better visual balance.
class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final cardHeight = isMobile ? 180.0 : 220.0;
    final cardWidth = isMobile ? 260.0 : 300.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.pagePadding,
          child: _buildSectionHeader(),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.pagePadding,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, index) => _TrendingCard(
              index: index,
              cardWidth: cardWidth,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department,
          color: AppColors.error,
          size: 22,
        ),
        const SizedBox(width: 6),
        Text('Trending Now', style: AppTypography.h3),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            'See All',
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.index, required this.cardWidth});

  final int index;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    // Placeholder project names for UI preview
    final names = [
      'Smart Campus',
      'AI Tutor',
      'EcoTrack',
      'CodeShare',
      'MedAssist',
    ];

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.code,
              size: 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Content
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Rank badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '#${index + 1} Trending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  names[index],
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.how_to_vote,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${50 - index * 8} votes',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

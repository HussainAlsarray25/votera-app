import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/home/presentation/demo_data.dart';

/// Podium display for the top 3 ranked projects.
/// Layout order: 2nd (left) - 1st (center, tallest) - 3rd (right).
class RankingsPodiumSection extends StatelessWidget {
  const RankingsPodiumSection({required this.topThree, super.key});

  final List<DemoProject> topThree;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place (left)
            Expanded(
              child: _PodiumItem(
                project: topThree.length > 1 ? topThree[1] : null,
                rank: 2,
                avatarSize: 68,
                bottomPadding: 16,
              ),
            ),
            // 1st place (center, tallest)
            Expanded(
              child: _PodiumItem(
                project: topThree.isNotEmpty ? topThree[0] : null,
                rank: 1,
                avatarSize: 82,
                bottomPadding: 0,
              ),
            ),
            // 3rd place (right)
            Expanded(
              child: _PodiumItem(
                project: topThree.length > 2 ? topThree[2] : null,
                rank: 3,
                avatarSize: 62,
                bottomPadding: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.project,
    required this.rank,
    required this.avatarSize,
    required this.bottomPadding,
  });

  final DemoProject? project;
  final int rank;
  final double avatarSize;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (project == null) return const SizedBox();

    final crownColor = _rankColor(rank);
    final borderColor = _rankBorderColor(rank);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown only for 1st place; spacer for others to keep alignment
          if (rank == 1)
            const Text('\u{1F451}', style: TextStyle(fontSize: 28))
          else
            const SizedBox(height: 28),
          const SizedBox(height: 4),
          _buildAvatar(crownColor, borderColor),
          const SizedBox(height: 10),
          _buildTitle(),
          const SizedBox(height: 2),
          _buildVotes(),
        ],
      ),
    );
  }

  /// Circular avatar with gradient fill, ring border, and rank badge
  Widget _buildAvatar(Color crownColor, Color borderColor) {
    final gradientColors =
        CategoryStyles.podiumGradient(project!.category);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: avatarSize + 8,
          height: avatarSize + 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor.withValues(alpha: 0.4),
              width: 3,
            ),
          ),
          child: Center(
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  project!.emoji,
                  style: TextStyle(fontSize: avatarSize * 0.4),
                ),
              ),
            ),
          ),
        ),
        // Rank badge
        Positioned(
          bottom: -4,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: crownColor,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: crownColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    final label = project!.title.length > 14
        ? '${project!.title.substring(0, 12)}...'
        : project!.title;

    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVotes() {
    return Text(
      '${project!.votes} Votes',
      style: TextStyle(
        fontSize: 12,
        fontWeight: rank == 1 ? FontWeight.w700 : FontWeight.w500,
        color: rank == 1 ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  // Gold, silver, bronze mapping
  static Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  static Color _rankBorderColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFD1D5DB);
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

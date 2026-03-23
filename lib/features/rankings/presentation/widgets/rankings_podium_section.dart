import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Podium display for the top 3 ranked projects.
/// Layout order: 2nd (left) - 1st (center, tallest) - 3rd (right).
class RankingsPodiumSection extends StatelessWidget {
  const RankingsPodiumSection({required this.topThree, super.key});

  final List<LeaderboardEntryEntity> topThree;

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
                entry: topThree.length > 1 ? topThree[1] : null,
                rank: 2,
                avatarSize: 68,
                bottomPadding: 16,
              ),
            ),
            // 1st place (center, tallest)
            Expanded(
              child: _PodiumItem(
                entry: topThree.isNotEmpty ? topThree[0] : null,
                rank: 1,
                avatarSize: 82,
                bottomPadding: 0,
              ),
            ),
            // 3rd place (right)
            Expanded(
              child: _PodiumItem(
                entry: topThree.length > 2 ? topThree[2] : null,
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

/// Rank-based gradient colors for podium avatars.
const _podiumGradients = {
  1: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
  2: [Color(0xFFE5E7EB), Color(0xFFC0C0C0)],
  3: [Color(0xFFFED7AA), Color(0xFFCD7F32)],
};

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.avatarSize,
    required this.bottomPadding,
  });

  final LeaderboardEntryEntity? entry;
  final int rank;
  final double avatarSize;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (entry == null) return const SizedBox();

    final crownColor = _rankColor(rank);
    final borderColor = _rankBorderColor(rank);
    final gradientColors = _podiumGradients[rank] ??
        const [Color(0xFFE5E7EB), Color(0xFF9CA3AF)];

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
          _buildAvatar(crownColor, borderColor, gradientColors),
          const SizedBox(height: 10),
          _buildTitle(context),
          const SizedBox(height: 2),
          _buildVotes(context),
        ],
      ),
    );
  }

  /// Circular avatar with gradient fill, ring border, and rank badge
  Widget _buildAvatar(
    Color crownColor,
    Color borderColor,
    List<Color> gradientColors,
  ) {
    final initial =
        entry!.title.isNotEmpty ? entry!.title[0].toUpperCase() : '?';

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
                  initial,
                  style: TextStyle(
                    fontSize: avatarSize * 0.38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
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

  Widget _buildTitle(BuildContext context) {
    final label = entry!.title.length > 14
        ? '${entry!.title.substring(0, 12)}...'
        : entry!.title;

    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVotes(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.votesWithCount(entry!.voteCount),
      style: TextStyle(
        fontSize: 12,
        fontWeight: rank == 1 ? FontWeight.w700 : FontWeight.w500,
        color: rank == 1 ? context.colors.primary : context.colors.textSecondary,
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

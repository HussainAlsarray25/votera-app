import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';

/// A single ranked project row showing rank number, avatar, name,
/// vote count, and a chevron indicator.
class RankingsListItem extends StatelessWidget {
  const RankingsListItem({required this.entry, super.key});

  final LeaderboardEntryEntity entry;

  @override
  Widget build(BuildContext context) {
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
          _buildAvatar(),
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
        '${entry.rank}',
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial =
        entry.title.isNotEmpty ? entry.title[0].toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Text(
      entry.title,
      style: AppTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVoteCount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${entry.voteCount}',
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

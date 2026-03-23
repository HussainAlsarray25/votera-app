import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

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
        color: context.colors.surface,
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
          _buildRankNumber(context),
          const SizedBox(width: 12),
          _buildAvatar(),
          const SizedBox(width: 14),
          Expanded(child: _buildInfo(context)),
          _buildVoteCount(context),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.colors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildRankNumber(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        '${entry.rank}',
        style: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colors.textHint,
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

  Widget _buildInfo(BuildContext context) {
    return Text(
      entry.title,
      style: AppTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVoteCount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${entry.voteCount}',
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.votesLabel,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: context.colors.textHint,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';

/// Displays a single team member as a bordered row.
///
/// Shows a round avatar with the member's initials, their user ID, a "(you)"
/// suffix if [isCurrentUser] is true, and a leader badge when [isLeader] is
/// true. Pass [onRemove] to show a remove button — only applicable when the
/// viewer is the leader and the member is not the leader themselves.
class TeamMemberTile extends StatelessWidget {
  const TeamMemberTile({
    required this.member,
    required this.isLeader,
    this.isCurrentUser = false,
    this.onRemove,
    super.key,
  });

  final TeamMemberEntity member;
  final bool isLeader;
  final bool isCurrentUser;

  // Non-null only when the viewer is the leader and this member can be removed.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _MemberAvatar(userId: member.userId, isLeader: isLeader),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isCurrentUser
                            ? '${member.userId} (you)'
                            : member.userId,
                        style: AppTypography.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const _LeaderBadge(),
                    ],
                  ],
                ),
                if (member.joinedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Joined ${_formatDate(member.joinedAt!)}',
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined, size: 20),
              color: AppColors.error,
              tooltip: 'Remove member',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// -- Avatar -------------------------------------------------------------------

/// Round avatar showing up to two initials of the user ID.
/// Gold gradient for the leader; subtle secondary/primary for members.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.userId, required this.isLeader});

  final String userId;
  final bool isLeader;

  String get _initials {
    if (userId.length >= 2) return userId.substring(0, 2).toUpperCase();
    return userId.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isLeader
                  ? [AppColors.accent, const Color(0xFFF59E0B)]
                  : [
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLeader ? Colors.white : AppColors.secondary,
              ),
            ),
          ),
        ),
        // Crown overlay for the leader
        if (isLeader)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

// -- Leader badge -------------------------------------------------------------

class _LeaderBadge extends StatelessWidget {
  const _LeaderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        'Leader',
        style: AppTypography.caption.copyWith(
          color: const Color(0xFFB45309),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

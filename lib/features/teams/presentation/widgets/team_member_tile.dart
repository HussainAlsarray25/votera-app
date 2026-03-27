import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          _MemberAvatar(displayName: member.displayName, isLeader: isLeader),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isCurrentUser
                            ? '${member.displayName} ${AppLocalizations.of(context)!.youSuffix}'
                            : member.displayName,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader) ...[
                      SizedBox(width: AppSpacing.xs),
                      const _LeaderBadge(),
                    ],
                  ],
                ),
                if (member.joinedAt != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    AppLocalizations.of(context)!.joinedDate(_formatDate(member.joinedAt!)),
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.person_remove_outlined, size: AppSizes.iconMd),
              color: context.colors.error,
              tooltip: AppLocalizations.of(context)!.removeMemberTooltip,
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
  const _MemberAvatar({required this.displayName, required this.isLeader});

  final String displayName;
  final bool isLeader;

  String get _initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (displayName.length >= 2) return displayName.substring(0, 2).toUpperCase();
    return displayName.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isLeader
                  ? [context.colors.accent, const Color(0xFFF59E0B)]
                  : [
                      context.colors.secondary.withValues(alpha: 0.15),
                      context.colors.primary.withValues(alpha: 0.15),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isLeader ? Colors.white : context.colors.secondary,
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
              width: 18.r,
              height: 18.r,
              decoration: BoxDecoration(
                color: context.colors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: AppSizes.iconXs,
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        AppLocalizations.of(context)!.leader,
        style: AppTypography.caption.copyWith(
          color: context.colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

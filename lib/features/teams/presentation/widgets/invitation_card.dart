import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/teams/domain/entities/invitation_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// Card shown to the current user for a pending team invitation.
///
/// Displays the team ID and inviter, with Accept and Decline action buttons.
/// Both buttons are disabled while [isLoading] is true to prevent double-taps.
class InvitationCard extends StatelessWidget {
  const InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
    this.isLoading = false,
    super.key,
  });

  final InvitationEntity invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: context.colors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: context.colors.secondary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvitationHeader(invitation: invitation),
            Divider(height: 1, thickness: 1, color: context.colors.divider),
            _InvitationActions(
              onAccept: onAccept,
              onDecline: onDecline,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

// -- Header -------------------------------------------------------------------

class _InvitationHeader extends StatelessWidget {
  const _InvitationHeader({required this.invitation});

  final InvitationEntity invitation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.secondary, context.colors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              Icons.mail_outline_rounded,
              color: Colors.white,
              size: AppSizes.iconMd,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.teamInvitation,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)!.teamLabel(invitation.teamId),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)!.invitedBy(invitation.invitedBy),
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const _PendingBadge(),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        AppLocalizations.of(context)!.pending,
        style: AppTypography.caption.copyWith(
          color: context.colors.warning,
          fontWeight: FontWeight.w700,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

// -- Actions ------------------------------------------------------------------

class _InvitationActions extends StatelessWidget {
  const _InvitationActions({
    required this.onAccept,
    required this.onDecline,
    required this.isLoading,
  });

  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: AppLocalizations.of(context)!.decline,
              icon: Icons.close_rounded,
              color: context.colors.error,
              onPressed: isLoading ? null : onDecline,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ActionButton(
              label: AppLocalizations.of(context)!.accept,
              icon: Icons.check_rounded,
              color: context.colors.success,
              filled: true,
              onPressed: isLoading ? null : onAccept,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconSm, color: filled ? Colors.white : color),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: filled ? Colors.white : color,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

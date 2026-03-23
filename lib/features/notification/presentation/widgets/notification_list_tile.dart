import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/l10n/gen/app_localizations.dart';

/// A single notification row showing title, body, time, and read status.
class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeLabel = _formatTime(context, notification.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? context.colors.primary.withValues(alpha: 0.06)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isUnread
                ? context.colors.primary.withValues(alpha: 0.15)
                : context.colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnread
                    ? context.colors.primary.withValues(alpha: 0.12)
                    : context.colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnread
                      ? context.colors.primary.withValues(alpha: 0.2)
                      : context.colors.border,
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: isUnread
                    ? context.colors.primary
                    : context.colors.textHint,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        timeLabel,
                        style: AppTypography.caption.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                    ],
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.body,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Unread dot
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: AppSpacing.xs),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

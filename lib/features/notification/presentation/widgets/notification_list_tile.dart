import 'package:flutter/material.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';

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
                        _formatTime(notification.createdAt),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

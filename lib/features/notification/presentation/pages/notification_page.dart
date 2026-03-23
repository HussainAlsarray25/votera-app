import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart' as di;
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/unread_count_cubit.dart';
import 'package:votera/features/notification/presentation/widgets/notification_list_tile.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (_) => di.sl<NotificationCubit>()..loadNotifications(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded) return const SizedBox.shrink();
              if (!state.notifications.any((n) => !n.isRead)) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () {
                  context
                      .read<NotificationCubit>()
                      .markAllNotificationsAsRead();
                  context.read<UnreadCountCubit>().clear();
                },
                child: Text(
                  'Mark all read',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: CenteredContent(
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Padding(
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () =>
                            context.read<NotificationCubit>().loadNotifications(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is NotificationLoaded) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<NotificationCubit>().loadNotifications(),
                color: AppColors.primary,
                child: state.notifications.isEmpty
                    ? _buildEmpty()
                    : _buildList(context, state.notifications),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No notifications yet',
                  style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Updates about events, votes, and results will appear here.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    // Group notifications into Today, Yesterday, and Earlier.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = notifications
        .where((n) => !n.createdAt.isBefore(today))
        .toList();
    final yesterdayItems = notifications
        .where(
          (n) =>
              !n.createdAt.isBefore(yesterday) && n.createdAt.isBefore(today),
        )
        .toList();
    final earlierItems = notifications
        .where((n) => n.createdAt.isBefore(yesterday))
        .toList();

    return ListView(
      padding: AppSpacing.pagePadding.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.xxl,
      ),
      children: [
        if (todayItems.isNotEmpty) ...[
          _SectionHeader(label: 'Today'),
          const SizedBox(height: AppSpacing.sm),
          ..._buildTiles(context, todayItems),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (yesterdayItems.isNotEmpty) ...[
          _SectionHeader(label: 'Yesterday'),
          const SizedBox(height: AppSpacing.sm),
          ..._buildTiles(context, yesterdayItems),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (earlierItems.isNotEmpty) ...[
          _SectionHeader(label: 'Earlier'),
          const SizedBox(height: AppSpacing.sm),
          ..._buildTiles(context, earlierItems),
        ],
      ],
    );
  }

  List<Widget> _buildTiles(
    BuildContext context,
    List<NotificationEntity> items,
  ) {
    return [
      for (int i = 0; i < items.length; i++) ...[
        NotificationListTile(
          notification: items[i],
          onTap: () {
            if (!items[i].isRead) {
              context
                  .read<NotificationCubit>()
                  .markNotificationAsRead(items[i].id);
              context.read<UnreadCountCubit>().decrement();
            }
          },
        ),
        if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
      ],
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

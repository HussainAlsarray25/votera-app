import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/design_system/design_system.dart';
import 'package:votera/core/di/injection_container.dart' as di;
import 'package:votera/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/unread_count_cubit.dart';
import 'package:votera/features/notification/presentation/widgets/notification_list_tile.dart';
import 'package:votera/shared/widgets/app_loading_indicator.dart';
import 'package:votera/shared/widgets/empty_state.dart';

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
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded) return const SizedBox.shrink();

              final hasUnread = state.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  context.read<NotificationCubit>().markAllNotificationsAsRead();
                  // Also clear the shell badge count.
                  context.read<UnreadCountCubit>().clear();
                },
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
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
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () {
                        context.read<NotificationCubit>().loadNotifications();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is NotificationLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<NotificationCubit>().loadNotifications();
              },
              child: state.notifications.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications yet',
                          subtitle:
                              'When you receive updates about events, votes, or results, they will appear here.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return NotificationListTile(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context
                                  .read<NotificationCubit>()
                                  .markNotificationAsRead(notification.id);
                              context.read<UnreadCountCubit>().decrement();
                            }
                          },
                        );
                      },
                    ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

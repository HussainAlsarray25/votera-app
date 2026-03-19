import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/features/notification/domain/usecases/get_notifications.dart';
import 'package:votera/features/notification/domain/usecases/mark_all_as_read.dart';
import 'package:votera/features/notification/domain/usecases/mark_as_read.dart';

part 'notification_state.dart';

/// Manages notification list loading, mark-as-read, and mark-all-as-read.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required this.getNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
  }) : super(NotificationInitial());

  final GetNotifications getNotifications;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    final result = await getNotifications(NoParams());
    result.fold(
      (failure) => emit(
        NotificationError(message: failure.message),
      ),
      (notifications) => emit(
        NotificationLoaded(notifications: notifications),
      ),
    );
  }

  /// Marks a single notification as read with optimistic update.
  Future<void> markNotificationAsRead(String id) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update: mark read locally before the server confirms.
    final updated = currentState.notifications.map((n) {
      if (n.id == id) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          body: n.body,
          createdAt: n.createdAt,
          isRead: true,
        );
      }
      return n;
    }).toList();
    emit(NotificationLoaded(notifications: updated));

    final result = await markAsRead(MarkAsReadParams(id: id));
    result.fold(
      // Revert on failure by reloading.
      (_) => loadNotifications(),
      (_) {},
    );
  }

  /// Marks all notifications as read, then refreshes the list.
  Future<void> markAllNotificationsAsRead() async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update: mark all read locally.
    final updated = currentState.notifications.map((n) {
      return NotificationEntity(
        id: n.id,
        title: n.title,
        body: n.body,
        createdAt: n.createdAt,
        isRead: true,
      );
    }).toList();
    emit(NotificationLoaded(notifications: updated));

    final result = await markAllAsRead(NoParams());
    result.fold(
      (_) => loadNotifications(),
      (_) {},
    );
  }
}

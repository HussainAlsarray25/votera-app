import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/features/notification/domain/usecases/get_notifications.dart';

part 'notification_state.dart';

/// Manages notification list loading.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required this.getNotifications})
      : super(NotificationInitial());

  final GetNotifications getNotifications;

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
}

part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({required this.notifications});

  final List<NotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  const NotificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

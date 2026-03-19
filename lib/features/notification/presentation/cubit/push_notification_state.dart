import 'package:equatable/equatable.dart';

abstract class PushNotificationState extends Equatable {
  const PushNotificationState();

  @override
  List<Object?> get props => [];
}

class PushNotificationInitial extends PushNotificationState {
  const PushNotificationInitial();
}

class PushNotificationRegistered extends PushNotificationState {
  const PushNotificationRegistered({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}

class PushNotificationUnregistered extends PushNotificationState {
  const PushNotificationUnregistered();
}

class PushNotificationError extends PushNotificationState {
  const PushNotificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

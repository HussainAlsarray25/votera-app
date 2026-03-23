part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// User is authenticated (tokens stored). Profile is fetched separately.
/// [fromTelegram] is true when authentication completed via the Telegram bot
/// polling flow, used to trigger a local notification while the app is in the
/// background.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({this.fromTelegram = false});

  final bool fromTelegram;

  @override
  List<Object?> get props => [fromTelegram];
}

/// Login returned a pending OTP verification step.
class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.identifier});

  final String identifier;

  @override
  List<Object?> get props => [identifier];
}

/// Registration accepted (202); user must verify OTP before tokens are issued.
class AuthRegistrationOtpRequired extends AuthState {
  const AuthRegistrationOtpRequired({required this.identifier});

  final String identifier;

  @override
  List<Object?> get props => [identifier];
}

/// Link has been obtained from the backend. The widget should open Telegram
/// via url_launcher and then the cubit will poll until authentication completes.
class AuthTelegramAwaitingUser extends AuthState {
  const AuthTelegramAwaitingUser({required this.link, required this.token});

  final String link;
  final String token;

  @override
  List<Object?> get props => [link, token];
}

class AuthPasswordResetSent extends AuthState {}

class AuthPasswordResetConfirmed extends AuthState {}

class AuthPasswordChanged extends AuthState {}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

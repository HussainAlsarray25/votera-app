part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// User is authenticated (tokens stored). Profile is fetched separately.
class AuthAuthenticated extends AuthState {}

/// Login returned a pending OTP verification step.
class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({required this.identifier});

  final String identifier;

  @override
  List<Object?> get props => [identifier];
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

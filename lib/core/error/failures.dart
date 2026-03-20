import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, this.statusCode});

  /// The HTTP status code returned by the server, if available.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message, this.isDeniedForever = false});

  final bool isDeniedForever;

  @override
  List<Object> get props => [message, isDeniedForever];
}

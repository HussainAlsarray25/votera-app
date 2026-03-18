part of 'participants_cubit.dart';

abstract class ApplicationsState extends Equatable {
  const ApplicationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action has been dispatched.
class ApplicationsInitial extends ApplicationsState {
  const ApplicationsInitial();
}

/// Emitted while any async operation is in progress.
class ApplicationsLoading extends ApplicationsState {
  const ApplicationsLoading();
}

/// Emitted when the application list has been loaded successfully.
class ApplicationsLoaded extends ApplicationsState {
  const ApplicationsLoaded({required this.applications});

  final PaginatedResponse<ApplicationEntity> applications;

  @override
  List<Object?> get props => [applications];
}

/// Emitted when the authenticated user's own application record is loaded.
class MyApplicationLoaded extends ApplicationsState {
  const MyApplicationLoaded({required this.application});

  final ApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

/// Emitted when a team has successfully submitted an application.
class ApplicationSubmitted extends ApplicationsState {
  const ApplicationSubmitted({required this.application});

  final ApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

/// Emitted when any operation fails.
class ApplicationsError extends ApplicationsState {
  const ApplicationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

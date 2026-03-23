part of 'events_cubit.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

/// Emitted when a page of events has been loaded successfully.
class EventsLoaded extends EventsState {
  const EventsLoaded({required this.response});

  final PaginatedResponse<EventEntity> response;

  @override
  List<Object?> get props => [response];
}

class EventsError extends EventsState {
  const EventsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

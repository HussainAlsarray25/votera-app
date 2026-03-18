import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/events/domain/usecases/get_events.dart';

part 'events_state.dart';

/// Manages the state for the events list screen.
/// Supports optional status filtering and explicit pagination via [loadEvents].
class EventsCubit extends Cubit<EventsState> {
  EventsCubit({required this.getEvents}) : super(const EventsInitial());

  final GetEvents getEvents;

  /// Loads a page of events from the repository.
  /// Pass [status] to restrict results to a specific lifecycle stage.
  Future<void> loadEvents({
    EventStatus? status,
    int page = 1,
    int size = 20,
  }) async {
    emit(const EventsLoading());

    final result = await getEvents(
      GetEventsParams(status: status, page: page, size: size),
    );

    result.fold(
      (failure) => emit(EventsError(message: failure.message)),
      (response) => emit(EventsLoaded(response: response)),
    );
  }
}

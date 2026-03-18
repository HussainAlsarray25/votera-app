import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';

abstract class EventRepository {
  /// Fetches a paginated list of events.
  /// Optionally filtered by [status]. [page] and [size] control pagination.
  Future<Either<Failure, PaginatedResponse<EventEntity>>> getEvents({
    EventStatus? status,
    required int page,
    required int size,
  });

  /// Fetches a single event by its unique identifier.
  Future<Either<Failure, EventEntity>> getEventById(String id);
}

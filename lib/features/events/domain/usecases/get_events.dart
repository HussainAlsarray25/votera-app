import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/events/domain/repositories/event_repository.dart';

/// Input parameters for [GetEvents].
class GetEventsParams extends Equatable {
  const GetEventsParams({
    this.status,
    required this.page,
    required this.size,
  });

  /// Optional filter. When null, all statuses are returned.
  final EventStatus? status;
  final int page;
  final int size;

  @override
  List<Object?> get props => [status, page, size];
}

/// Returns a paginated list of events, optionally filtered by status.
class GetEvents
    extends UseCase<PaginatedResponse<EventEntity>, GetEventsParams> {
  GetEvents(this.repository);

  final EventRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<EventEntity>>> call(
    GetEventsParams params,
  ) {
    return repository.getEvents(
      status: params.status,
      page: params.page,
      size: params.size,
    );
  }
}

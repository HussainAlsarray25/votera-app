import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/events/domain/entities/event_entity.dart';
import 'package:votera/features/events/domain/repositories/event_repository.dart';

/// Input parameters for [GetEventById].
class GetEventByIdParams extends Equatable {
  const GetEventByIdParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Fetches a single event by its ID.
class GetEventById extends UseCase<EventEntity, GetEventByIdParams> {
  GetEventById(this.repository);

  final EventRepository repository;

  @override
  Future<Either<Failure, EventEntity>> call(GetEventByIdParams params) {
    return repository.getEventById(params.id);
  }
}

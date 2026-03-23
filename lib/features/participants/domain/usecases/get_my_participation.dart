import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';

/// Input parameters for [GetMyApplication].
class GetMyApplicationParams extends Equatable {
  const GetMyApplicationParams({
    required this.eventId,
    required this.teamId,
  });

  final String eventId;
  final String teamId;

  @override
  List<Object> get props => [eventId, teamId];
}

/// Returns the authenticated user's team application for an event.
class GetMyApplication
    extends UseCase<ApplicationEntity, GetMyApplicationParams> {
  GetMyApplication(this.repository);

  final ApplicationRepository repository;

  @override
  Future<Either<Failure, ApplicationEntity>> call(
    GetMyApplicationParams params,
  ) {
    return repository.getMyApplication(
      eventId: params.eventId,
      teamId: params.teamId,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';

/// Input parameters for [SubmitApplication].
class SubmitApplicationParams extends Equatable {
  const SubmitApplicationParams({
    required this.eventId,
    required this.teamId,
  });

  final String eventId;
  final String teamId;

  @override
  List<Object> get props => [eventId, teamId];
}

/// Submits an application for a team to participate in an event.
class SubmitApplication
    extends UseCase<ApplicationEntity, SubmitApplicationParams> {
  SubmitApplication(this.repository);

  final ApplicationRepository repository;

  @override
  Future<Either<Failure, ApplicationEntity>> call(
    SubmitApplicationParams params,
  ) {
    return repository.submitApplication(
      eventId: params.eventId,
      teamId: params.teamId,
    );
  }
}

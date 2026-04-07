import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class GetMyProject extends UseCase<ProjectEntity, GetMyProjectParams> {
  GetMyProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(GetMyProjectParams params) {
    return repository.getMyProject(
      eventId: params.eventId,
      teamId: params.teamId,
    );
  }
}

class GetMyProjectParams extends Equatable {
  const GetMyProjectParams({required this.eventId, this.teamId});

  final String eventId;

  /// Required when the user belongs to multiple teams.
  final String? teamId;

  @override
  List<Object?> get props => [eventId, teamId];
}

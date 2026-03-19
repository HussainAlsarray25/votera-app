import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class CancelProjectParams extends Equatable {
  const CancelProjectParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object> get props => [eventId, projectId];
}

class CancelProject extends UseCase<ProjectEntity, CancelProjectParams> {
  CancelProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(CancelProjectParams params) {
    return repository.cancelProject(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

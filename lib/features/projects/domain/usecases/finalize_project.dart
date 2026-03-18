import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class FinalizeProjectParams extends Equatable {
  const FinalizeProjectParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object> get props => [eventId, projectId];
}

/// Transitions a project from draft to submitted status.
class FinalizeProject extends UseCase<ProjectEntity, FinalizeProjectParams> {
  FinalizeProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(FinalizeProjectParams params) {
    return repository.finalizeProject(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

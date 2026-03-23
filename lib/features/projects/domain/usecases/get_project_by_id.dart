import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class GetProjectById extends UseCase<ProjectEntity, GetProjectByIdParams> {
  GetProjectById(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(GetProjectByIdParams params) {
    return repository.getProjectById(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

class GetProjectByIdParams extends Equatable {
  const GetProjectByIdParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object?> get props => [eventId, projectId];
}

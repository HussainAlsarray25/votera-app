import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class UpdateProject extends UseCase<ProjectEntity, UpdateProjectParams> {
  UpdateProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(UpdateProjectParams params) {
    return repository.updateProject(
      eventId: params.eventId,
      projectId: params.projectId,
      title: params.title,
      description: params.description,
      repoUrl: params.repoUrl,
      demoUrl: params.demoUrl,
    );
  }
}

class UpdateProjectParams extends Equatable {
  const UpdateProjectParams({
    required this.eventId,
    required this.projectId,
    this.title,
    this.description,
    this.repoUrl,
    this.demoUrl,
  });

  final String eventId;
  final String projectId;

  /// All fields are optional because the API accepts partial updates.
  final String? title;
  final String? description;
  final String? repoUrl;
  final String? demoUrl;

  @override
  List<Object?> get props => [eventId, projectId, title, description, repoUrl, demoUrl];
}

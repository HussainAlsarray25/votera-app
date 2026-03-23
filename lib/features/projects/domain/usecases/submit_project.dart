import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class SubmitProject extends UseCase<ProjectEntity, SubmitProjectParams> {
  SubmitProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, ProjectEntity>> call(SubmitProjectParams params) {
    return repository.submitProject(
      eventId: params.eventId,
      title: params.title,
      description: params.description,
      repoUrl: params.repoUrl,
      demoUrl: params.demoUrl,
      techStack: params.techStack,
    );
  }
}

class SubmitProjectParams extends Equatable {
  const SubmitProjectParams({
    required this.eventId,
    required this.title,
    this.description,
    this.repoUrl,
    this.demoUrl,
    this.techStack,
  });

  final String eventId;
  final String title;
  final String? description;
  final String? repoUrl;
  final String? demoUrl;
  final String? techStack;

  @override
  List<Object?> get props => [eventId, title, description, repoUrl, demoUrl, techStack];
}

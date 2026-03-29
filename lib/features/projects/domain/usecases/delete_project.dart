import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectParams extends Equatable {
  const DeleteProjectParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object> get props => [eventId, projectId];
}

/// Permanently deletes a draft project.
/// Only allowed while the project is in draft status;
/// the backend will reject attempts on submitted/accepted/rejected projects.
class DeleteProject extends UseCase<void, DeleteProjectParams> {
  DeleteProject(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) {
    return repository.deleteProject(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

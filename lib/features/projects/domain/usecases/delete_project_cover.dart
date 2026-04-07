import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectCover extends UseCase<void, DeleteProjectCoverParams> {
  DeleteProjectCover(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteProjectCoverParams params) {
    return repository.deleteCover(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

class DeleteProjectCoverParams extends Equatable {
  const DeleteProjectCoverParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object?> get props => [eventId, projectId];
}

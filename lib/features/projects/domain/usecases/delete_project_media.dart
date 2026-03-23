import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectMediaParams extends Equatable {
  const DeleteProjectMediaParams({
    required this.eventId,
    required this.projectId,
    required this.mediaId,
  });

  final String eventId;
  final String projectId;
  final String mediaId;

  @override
  List<Object> get props => [eventId, projectId, mediaId];
}

class DeleteProjectMedia extends UseCase<void, DeleteProjectMediaParams> {
  DeleteProjectMedia(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteProjectMediaParams params) {
    return repository.deleteProjectMedia(
      eventId: params.eventId,
      projectId: params.projectId,
      mediaId: params.mediaId,
    );
  }
}

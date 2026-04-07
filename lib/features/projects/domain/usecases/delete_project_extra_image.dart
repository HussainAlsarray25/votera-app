import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectExtraImage
    extends UseCase<void, DeleteProjectExtraImageParams> {
  DeleteProjectExtraImage(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteProjectExtraImageParams params) {
    return repository.deleteExtraImage(
      eventId: params.eventId,
      projectId: params.projectId,
      imageId: params.imageId,
    );
  }
}

class DeleteProjectExtraImageParams extends Equatable {
  const DeleteProjectExtraImageParams({
    required this.eventId,
    required this.projectId,
    required this.imageId,
  });

  final String eventId;
  final String projectId;

  /// The ID returned when the image was uploaded (from the upload response).
  final String imageId;

  @override
  List<Object?> get props => [eventId, projectId, imageId];
}

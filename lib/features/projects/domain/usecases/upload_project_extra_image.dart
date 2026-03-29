import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class UploadProjectExtraImage
    extends UseCase<MediaUploadResponseEntity, UploadProjectExtraImageParams> {
  UploadProjectExtraImage(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, MediaUploadResponseEntity>> call(
    UploadProjectExtraImageParams params,
  ) {
    return repository.uploadExtraImage(
      eventId: params.eventId,
      projectId: params.projectId,
      bytes: params.bytes,
      contentType: params.contentType,
    );
  }
}

class UploadProjectExtraImageParams extends Equatable {
  const UploadProjectExtraImageParams({
    required this.eventId,
    required this.projectId,
    required this.bytes,
    required this.contentType,
  });

  final String eventId;
  final String projectId;

  /// Raw image bytes to upload (max 5 MB).
  /// The project may hold up to 6 extra images.
  final List<int> bytes;

  /// MIME type of the image (e.g. "image/jpeg", "image/png").
  final String contentType;

  @override
  List<Object?> get props => [eventId, projectId, bytes, contentType];
}

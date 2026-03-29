import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class UploadProjectCover
    extends UseCase<MediaUploadResponseEntity, UploadProjectCoverParams> {
  UploadProjectCover(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, MediaUploadResponseEntity>> call(
    UploadProjectCoverParams params,
  ) {
    return repository.uploadCover(
      eventId: params.eventId,
      projectId: params.projectId,
      bytes: params.bytes,
      contentType: params.contentType,
    );
  }
}

class UploadProjectCoverParams extends Equatable {
  const UploadProjectCoverParams({
    required this.eventId,
    required this.projectId,
    required this.bytes,
    required this.contentType,
  });

  final String eventId;
  final String projectId;

  /// Raw image bytes to upload (max 5 MB).
  final List<int> bytes;

  /// MIME type of the image (e.g. "image/jpeg", "image/png").
  final String contentType;

  @override
  List<Object?> get props => [eventId, projectId, bytes, contentType];
}

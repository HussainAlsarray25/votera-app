import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/upload_url_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class GetUploadUrl extends UseCase<UploadUrlEntity, GetUploadUrlParams> {
  GetUploadUrl(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, UploadUrlEntity>> call(GetUploadUrlParams params) {
    return repository.getUploadUrl(
      eventId: params.eventId,
      projectId: params.projectId,
      fileName: params.fileName,
      fileType: params.fileType,
    );
  }
}

class GetUploadUrlParams extends Equatable {
  const GetUploadUrlParams({
    required this.eventId,
    required this.projectId,
    required this.fileName,
    this.fileType,
  });

  final String eventId;
  final String projectId;

  /// The original file name used to generate the storage key.
  final String fileName;

  /// Optional MIME type (e.g. "image/jpeg"). Server may infer from fileName.
  final String? fileType;

  @override
  List<Object?> get props => [eventId, projectId, fileName, fileType];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/certifications/domain/entities/upload_url_entity.dart';
import 'package:votera/features/certifications/domain/repositories/certification_repository.dart';

class GetCertificationUploadUrlParams extends Equatable {
  const GetCertificationUploadUrlParams({
    required this.type,
    required this.fileName,
    required this.contentType,
  });

  final String type;
  final String fileName;
  final String contentType;

  @override
  List<Object> get props => [type, fileName, contentType];
}

class GetCertificationUploadUrl
    extends UseCase<CertificationUploadUrlEntity, GetCertificationUploadUrlParams> {
  GetCertificationUploadUrl(this.repository);

  final CertificationRepository repository;

  @override
  Future<Either<Failure, CertificationUploadUrlEntity>> call(
    GetCertificationUploadUrlParams params,
  ) {
    return repository.getUploadUrl(
      type: params.type,
      fileName: params.fileName,
      contentType: params.contentType,
    );
  }
}

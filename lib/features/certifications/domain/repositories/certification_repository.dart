import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';
import 'package:votera/features/certifications/domain/entities/upload_url_entity.dart';

abstract class CertificationRepository {
  /// Submits a new certification request.
  Future<Either<Failure, CertificationEntity>> submitCertification({
    required CertificationType type,
    required String documentUrl,
  });

  /// Returns the authenticated user's certification of the given [type].
  Future<Either<Failure, CertificationEntity>> getMyCertification(
    CertificationType type,
  );

  /// Requests a pre-signed upload URL for a certification document.
  Future<Either<Failure, CertificationUploadUrlEntity>> getUploadUrl({
    required String type,
    required String fileName,
    required String contentType,
  });
}

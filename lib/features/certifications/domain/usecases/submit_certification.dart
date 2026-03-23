import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';
import 'package:votera/features/certifications/domain/repositories/certification_repository.dart';

class SubmitCertificationParams extends Equatable {
  const SubmitCertificationParams({
    required this.type,
    required this.documentUrl,
  });

  final CertificationType type;
  final String documentUrl;

  @override
  List<Object> get props => [type, documentUrl];
}

class SubmitCertification
    extends UseCase<CertificationEntity, SubmitCertificationParams> {
  SubmitCertification(this.repository);

  final CertificationRepository repository;

  @override
  Future<Either<Failure, CertificationEntity>> call(
    SubmitCertificationParams params,
  ) {
    return repository.submitCertification(
      type: params.type,
      documentUrl: params.documentUrl,
    );
  }
}

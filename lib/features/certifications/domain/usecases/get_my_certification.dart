import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';
import 'package:votera/features/certifications/domain/repositories/certification_repository.dart';

class GetMyCertificationParams extends Equatable {
  const GetMyCertificationParams({required this.type});

  final CertificationType type;

  @override
  List<Object> get props => [type];
}

class GetMyCertification
    extends UseCase<CertificationEntity, GetMyCertificationParams> {
  GetMyCertification(this.repository);

  final CertificationRepository repository;

  @override
  Future<Either<Failure, CertificationEntity>> call(
    GetMyCertificationParams params,
  ) {
    return repository.getMyCertification(params.type);
  }
}

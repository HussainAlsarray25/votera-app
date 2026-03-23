import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/certifications/data/datasources/remote/certification_remote_data_source.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';
import 'package:votera/features/certifications/domain/entities/upload_url_entity.dart';
import 'package:votera/features/certifications/domain/repositories/certification_repository.dart';

class CertificationRepositoryImpl implements CertificationRepository {
  const CertificationRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final CertificationRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, CertificationEntity>> submitCertification({
    required CertificationType type,
    required String documentUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.submitCertification(
        type: type,
        documentUrl: documentUrl,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, CertificationEntity>> getMyCertification(
    CertificationType type,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getMyCertification(type);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, CertificationUploadUrlEntity>> getUploadUrl({
    required String type,
    required String fileName,
    required String contentType,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getUploadUrl(
        type: type,
        fileName: fileName,
        contentType: contentType,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

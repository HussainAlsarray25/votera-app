import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/participant_forms/data/datasources/remote/forms_remote_data_source.dart';
import 'package:votera/features/participant_forms/data/models/participant_request_model.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class FormsRepositoryImpl implements FormsRepository {
  const FormsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final FormsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, void>> requestEmailOtp(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.requestEmailOtp(email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOtp(
      String email, String code) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.verifyEmailOtp(email, code);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<ParticipantRequest>>> getMyUidRequests() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final rawList = await remoteDataSource.getMyUidRequests();
      final requests = rawList
          .map((json) => ParticipantRequestModel.fromJson(json))
          .toList();
      return Right(requests);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ParticipantRequest>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required List<int> documentBytes,
    required String documentFileName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final response = await remoteDataSource.submitUidRequest(
        fullName: fullName,
        universityId: universityId,
        department: department,
        stage: stage,
        documentBytes: documentBytes,
        documentFileName: documentFileName,
      );
      final data = response['data'] as Map<String, dynamic>;
      return Right(ParticipantRequestModel.fromJson(data));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> requestSupervisorEmailOtp(String email) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.requestSupervisorEmailOtp(email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> verifySupervisorEmailOtp(
      String email, String code) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.verifySupervisorEmailOtp(email, code);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

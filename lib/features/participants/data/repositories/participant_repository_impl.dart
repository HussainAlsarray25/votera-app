import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/participants/data/datasources/remote/participant_remote_data_source.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  const ApplicationRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final ApplicationRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getApplications({
    required String eventId,
    required int page,
    required int size,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getApplications(
        eventId: eventId,
        page: page,
        size: size,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required String eventId,
    required String teamId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.submitApplication(
        eventId: eventId,
        teamId: teamId,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> getMyApplication({
    required String eventId,
    required String teamId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getMyApplication(
        eventId: eventId,
        teamId: teamId,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

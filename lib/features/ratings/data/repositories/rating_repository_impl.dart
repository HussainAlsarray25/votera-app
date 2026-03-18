import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/ratings/data/datasources/remote/rating_remote_data_source.dart';
import 'package:votera/features/ratings/domain/entities/rating_entity.dart';
import 'package:votera/features/ratings/domain/entities/rating_summary_entity.dart';
import 'package:votera/features/ratings/domain/repositories/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  const RatingRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final RatingRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, RatingEntity>> rateProject({
    required String projectId,
    required int score,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.rateProject(
        projectId: projectId,
        score: score,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary(
    String projectId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getRatingSummary(projectId);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, RatingEntity>> getMyRating(String projectId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getMyRating(projectId);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

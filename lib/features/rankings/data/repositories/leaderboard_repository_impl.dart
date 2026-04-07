import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/rankings/data/datasources/remote/leaderboard_remote_data_source.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_track.dart';
import 'package:votera/features/rankings/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final LeaderboardRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, LeaderboardEntity>> getLeaderboard(
    String eventId, {
    LeaderboardTrack track = LeaderboardTrack.all,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getLeaderboard(eventId, track: track);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, LeaderboardEntity>> getFinalResults(
    String eventId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getFinalResults(eventId);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

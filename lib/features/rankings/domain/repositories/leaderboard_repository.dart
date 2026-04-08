import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';

abstract class LeaderboardRepository {
  /// Fetches voting results for an event from GET /v1/events/{id}/votes/results.
  /// Returns the weighted overall result (no track filter).
  Future<Either<Failure, LeaderboardEntity>> getVotingResults(String eventId);
}

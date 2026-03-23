import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';

abstract class LeaderboardRepository {
  /// Fetches the live leaderboard for an event.
  /// Calls GET /v1/events/{event_id}/leaderboard.
  Future<Either<Failure, LeaderboardEntity>> getLeaderboard(String eventId);

  /// Fetches the final published results for an event.
  /// Calls GET /v1/events/{event_id}/leaderboard/final.
  Future<Either<Failure, LeaderboardEntity>> getFinalResults(String eventId);
}

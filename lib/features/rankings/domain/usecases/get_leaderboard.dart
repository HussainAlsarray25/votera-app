import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_track.dart';
import 'package:votera/features/rankings/domain/repositories/leaderboard_repository.dart';

/// Input parameters for [GetLeaderboard].
class GetLeaderboardParams extends Equatable {
  const GetLeaderboardParams({
    required this.eventId,
    this.track = LeaderboardTrack.all,
  });

  final String eventId;
  final LeaderboardTrack track;

  @override
  List<Object?> get props => [eventId, track];
}

/// Fetches the live leaderboard for a given event.
class GetLeaderboard extends UseCase<LeaderboardEntity, GetLeaderboardParams> {
  GetLeaderboard(this.repository);

  final LeaderboardRepository repository;

  @override
  Future<Either<Failure, LeaderboardEntity>> call(
    GetLeaderboardParams params,
  ) {
    return repository.getLeaderboard(params.eventId, track: params.track);
  }
}

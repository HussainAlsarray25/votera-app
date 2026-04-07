import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/repositories/leaderboard_repository.dart';

/// Input parameters for [GetVotingResults].
class GetVotingResultsParams extends Equatable {
  const GetVotingResultsParams({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

/// Fetches the weighted overall voting results for a given event.
class GetVotingResults extends UseCase<LeaderboardEntity, GetVotingResultsParams> {
  GetVotingResults(this.repository);

  final LeaderboardRepository repository;

  @override
  Future<Either<Failure, LeaderboardEntity>> call(
    GetVotingResultsParams params,
  ) {
    return repository.getVotingResults(params.eventId);
  }
}

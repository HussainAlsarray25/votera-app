import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';
import 'package:votera/features/rankings/domain/repositories/leaderboard_repository.dart';

/// Input parameters for [GetFinalResults].
class GetFinalResultsParams extends Equatable {
  const GetFinalResultsParams({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

/// Fetches the final published results for a given event.
class GetFinalResults extends UseCase<LeaderboardEntity, GetFinalResultsParams> {
  GetFinalResults(this.repository);

  final LeaderboardRepository repository;

  @override
  Future<Either<Failure, LeaderboardEntity>> call(
    GetFinalResultsParams params,
  ) {
    return repository.getFinalResults(params.eventId);
  }
}

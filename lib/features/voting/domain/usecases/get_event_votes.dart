import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class GetEventVotesParams extends Equatable {
  const GetEventVotesParams({required this.eventId});

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// Retrieves all votes for a given event.
class GetEventVotes extends UseCase<List<VoteEntity>, GetEventVotesParams> {
  GetEventVotes(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, List<VoteEntity>>> call(GetEventVotesParams params) {
    return repository.getEventVotes(eventId: params.eventId);
  }
}

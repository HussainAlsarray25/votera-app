import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class GetMyVotes extends UseCase<List<VoteEntity>, GetMyVotesParams> {
  GetMyVotes(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, List<VoteEntity>>> call(GetMyVotesParams params) {
    return repository.getMyVotes(eventId: params.eventId);
  }
}

class GetMyVotesParams extends Equatable {
  const GetMyVotesParams({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

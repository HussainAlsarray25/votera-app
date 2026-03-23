import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class CastVote extends UseCase<VoteEntity, CastVoteParams> {
  CastVote(this.repository);

  final VotingRepository repository;

  @override
  Future<Either<Failure, VoteEntity>> call(CastVoteParams params) {
    return repository.castVote(
      eventId: params.eventId,
      projectId: params.projectId,
    );
  }
}

class CastVoteParams extends Equatable {
  const CastVoteParams({
    required this.eventId,
    required this.projectId,
  });

  final String eventId;
  final String projectId;

  @override
  List<Object?> get props => [eventId, projectId];
}

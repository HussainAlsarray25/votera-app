import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/entities/voting_area_entity.dart';

abstract class VotingRepository {
  Future<Either<Failure, VoteEntity>> castVote({
    required String eventId,
    required String projectId,
  });

  Future<Either<Failure, List<VoteEntity>>> getMyVotes({
    required String eventId,
  });

  Future<Either<Failure, TallyEntity>> getVoteTally({
    required String eventId,
  });

  Future<Either<Failure, void>> retractVote({
    required String eventId,
    required String voteId,
  });

  Future<Either<Failure, List<VoteEntity>>> getEventVotes({
    required String eventId,
  });

  Future<Either<Failure, VotingAreaEntity>> getVotingArea({
    required String eventId,
  });
}

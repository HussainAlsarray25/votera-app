import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/voting/data/datasources/remote/voting_remote_data_source.dart';
import 'package:votera/features/voting/data/models/tally_model.dart';
import 'package:votera/features/voting/data/models/vote_model.dart';
import 'package:votera/features/voting/data/models/voting_area_model.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';
import 'package:votera/features/voting/domain/entities/vote_entity.dart';
import 'package:votera/features/voting/domain/entities/voting_area_entity.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';

class VotingRepositoryImpl implements VotingRepository {
  const VotingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final VotingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, VoteEntity>> castVote({
    required String eventId,
    required String projectId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.castVote(
        eventId: eventId,
        projectId: projectId,
      );
      return Right(VoteModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<VoteEntity>>> getMyVotes({
    required String eventId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getMyVotes(eventId: eventId);
      final votes = result.map(VoteModel.fromJson).toList();
      return Right(votes);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, TallyEntity>> getVoteTally({
    required String eventId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getVoteTally(eventId: eventId);
      return Right(TallyModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> retractVote({
    required String eventId,
    required String voteId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.retractVote(eventId: eventId, voteId: voteId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, List<VoteEntity>>> getEventVotes({
    required String eventId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getEventVotes(eventId: eventId);
      final votes = result.map(VoteModel.fromJson).toList();
      return Right(votes);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, VotingAreaEntity>> getVotingArea({
    required String eventId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getVotingArea(eventId: eventId);
      return Right(VotingAreaModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

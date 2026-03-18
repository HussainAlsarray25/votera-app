import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/comments/data/datasources/remote/comment_remote_data_source.dart';
import 'package:votera/features/comments/data/models/comment_model.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  const CommentRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final CommentRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<CommentEntity>>> getComments({
    required String projectId,
    required int page,
    required int size,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remote.getComments(
        projectId: projectId,
        page: page,
        size: size,
      );
      final paginated = PaginatedResponse.fromJson(
        json,
        CommentModel.fromJson,
      );
      return Right(paginated);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> postComment({
    required String projectId,
    required String body,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remote.postComment(
        projectId: projectId,
        body: body,
      );
      return Right(CommentModel.fromJson(json));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, CommentEntity>> updateComment({
    required String projectId,
    required String commentId,
    required String body,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remote.updateComment(
        projectId: projectId,
        commentId: commentId,
        body: body,
      );
      return Right(CommentModel.fromJson(json));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String projectId,
    required String commentId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remote.deleteComment(
        projectId: projectId,
        commentId: commentId,
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

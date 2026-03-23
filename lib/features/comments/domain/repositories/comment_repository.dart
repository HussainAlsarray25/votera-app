import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';

/// Contract for all comment data operations.
/// The implementation lives in the data layer and decides whether to
/// hit the network, a cache, or any other source.
abstract class CommentRepository {
  /// Fetch a paginated list of comments for a given project.
  Future<Either<Failure, PaginatedResponse<CommentEntity>>> getComments({
    required String projectId,
    required int page,
    required int size,
  });

  /// Post a new comment on a project.
  /// [score] is the 1–5 star rating the user selected alongside their text.
  Future<Either<Failure, CommentEntity>> postComment({
    required String projectId,
    required String text,
    required int score,
  });

  /// Update an existing comment's body.
  Future<Either<Failure, CommentEntity>> updateComment({
    required String projectId,
    required String commentId,
    required String body,
  });

  /// Delete a comment by its identifier.
  Future<Either<Failure, void>> deleteComment({
    required String projectId,
    required String commentId,
  });
}

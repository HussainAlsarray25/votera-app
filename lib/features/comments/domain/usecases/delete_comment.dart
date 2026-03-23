import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';

/// Deletes a comment by its identifier. Returns void on success.
class DeleteComment extends UseCase<void, DeleteCommentParams> {
  DeleteComment(this.repository);

  final CommentRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) {
    return repository.deleteComment(
      projectId: params.projectId,
      commentId: params.commentId,
    );
  }
}

/// Parameters for [DeleteComment].
class DeleteCommentParams extends Equatable {
  const DeleteCommentParams({
    required this.projectId,
    required this.commentId,
  });

  final String projectId;
  final String commentId;

  @override
  List<Object> get props => [projectId, commentId];
}

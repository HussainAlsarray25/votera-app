import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';

/// Updates an existing comment's body and returns the updated entity.
class UpdateComment extends UseCase<CommentEntity, UpdateCommentParams> {
  UpdateComment(this.repository);

  final CommentRepository repository;

  @override
  Future<Either<Failure, CommentEntity>> call(UpdateCommentParams params) {
    return repository.updateComment(
      projectId: params.projectId,
      commentId: params.commentId,
      body: params.body,
    );
  }
}

/// Parameters for [UpdateComment].
class UpdateCommentParams extends Equatable {
  const UpdateCommentParams({
    required this.projectId,
    required this.commentId,
    required this.body,
  });

  final String projectId;
  final String commentId;
  final String body;

  @override
  List<Object> get props => [projectId, commentId, body];
}

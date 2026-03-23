import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/domain/repositories/comment_repository.dart';

/// Posts a new comment on the given project and returns the created entity.
class PostComment extends UseCase<CommentEntity, PostCommentParams> {
  PostComment(this.repository);

  final CommentRepository repository;

  @override
  Future<Either<Failure, CommentEntity>> call(PostCommentParams params) {
    return repository.postComment(
      projectId: params.projectId,
      body: params.body,
    );
  }
}

/// Parameters for [PostComment].
class PostCommentParams extends Equatable {
  const PostCommentParams({
    required this.projectId,
    required this.body,
  });

  final String projectId;
  final String body;

  @override
  List<Object> get props => [projectId, body];
}

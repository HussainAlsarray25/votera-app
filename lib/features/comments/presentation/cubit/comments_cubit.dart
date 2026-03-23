import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/comments/domain/entities/comment_entity.dart';
import 'package:votera/features/comments/domain/usecases/delete_comment.dart';
import 'package:votera/features/comments/domain/usecases/get_comments.dart';
import 'package:votera/features/comments/domain/usecases/post_comment.dart';
import 'package:votera/features/comments/domain/usecases/update_comment.dart';

part 'comments_state.dart';

/// Manages the full lifecycle of comments for a single project:
/// loading, posting, editing, and deleting.
/// Each action emits a focused state so the UI can react granularly
/// without forcing a full list reload after every mutation.
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required this.getComments,
    required this.postComment,
    required this.updateComment,
    required this.deleteComment,
  }) : super(const CommentsInitial());

  final GetComments getComments;
  final PostComment postComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;

  /// Load the first page of comments for [projectId].
  Future<void> loadComments({
    required String projectId,
    int page = 1,
    int size = 20,
  }) async {
    emit(const CommentsLoading());
    final result = await getComments(
      GetCommentsParams(projectId: projectId, page: page, size: size),
    );
    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (paginated) => emit(
        CommentsLoaded(
          comments: paginated.items,
          page: paginated.page,
          hasNextPage: paginated.hasNextPage,
        ),
      ),
    );
  }

  /// Post a new comment on [projectId]. Emits [CommentPosted] on success
  /// so the UI can prepend the new item without a full list reload.
  Future<void> addComment({
    required String projectId,
    required String text,
    required int score,
  }) async {
    final result = await postComment(
      PostCommentParams(projectId: projectId, text: text, score: score),
    );
    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (comment) => emit(CommentPosted(comment: comment)),
    );
  }

  /// Update an existing comment. Emits [CommentUpdated] on success so the UI
  /// can swap the edited item in place.
  Future<void> editComment({
    required String projectId,
    required String commentId,
    required String body,
  }) async {
    final result = await updateComment(
      UpdateCommentParams(
        projectId: projectId,
        commentId: commentId,
        body: body,
      ),
    );
    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (comment) => emit(CommentUpdated(comment: comment)),
    );
  }

  /// Delete a comment. Emits [CommentDeleted] with the removed comment's ID
  /// so the UI can remove it from the list without refetching.
  Future<void> removeComment({
    required String projectId,
    required String commentId,
  }) async {
    final result = await deleteComment(
      DeleteCommentParams(projectId: projectId, commentId: commentId),
    );
    result.fold(
      (failure) => emit(CommentsError(message: failure.message)),
      (_) => emit(CommentDeleted(commentId: commentId)),
    );
  }
}

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

  /// Load a specific page of comments for [projectId].
  Future<void> loadComments({
    required String projectId,
    int page = 1,
    int size = 10,
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
          total: paginated.total,
          pageSize: size,
        ),
      ),
    );
  }

  /// Post a new comment on [projectId].
  /// Emits [CommentPosted] immediately for instant UI feedback, then silently
  /// reloads the comment list to get authoritative data from the server
  /// (the POST response may return empty author name/avatar).
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
      (comment) async {
        emit(CommentPosted(comment: comment));

        // Reload silently — no loading spinner so the UI stays stable.
        final refreshResult = await getComments(
          GetCommentsParams(projectId: projectId, page: 1, size: 10),
        );
        refreshResult.fold(
          (_) {},  // Ignore refresh errors; the comment is already visible.
          (paginated) => emit(CommentsLoaded(
            comments: paginated.items,
            page: paginated.page,
            total: paginated.total,
            pageSize: 10,
          )),
        );
      },
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

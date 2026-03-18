part of 'comments_cubit.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

/// Emitted when the comment list has been successfully loaded or refreshed.
/// Carries pagination metadata so the UI can decide whether to show a
/// "load more" trigger.
class CommentsLoaded extends CommentsState {
  const CommentsLoaded({
    required this.comments,
    required this.page,
    required this.hasNextPage,
  });

  final List<CommentEntity> comments;
  final int page;
  final bool hasNextPage;

  @override
  List<Object?> get props => [comments, page, hasNextPage];
}

/// Emitted after a comment is successfully posted so the UI can
/// optimistically insert it without a full reload.
class CommentPosted extends CommentsState {
  const CommentPosted({required this.comment});

  final CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

/// Emitted after a comment is successfully updated.
class CommentUpdated extends CommentsState {
  const CommentUpdated({required this.comment});

  final CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

/// Emitted after a comment is successfully deleted.
class CommentDeleted extends CommentsState {
  const CommentDeleted({required this.commentId});

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

class CommentsError extends CommentsState {
  const CommentsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

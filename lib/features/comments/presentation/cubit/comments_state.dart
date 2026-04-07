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
/// Carries full pagination metadata so the UI can render numbered page buttons.
class CommentsLoaded extends CommentsState {
  const CommentsLoaded({
    required this.comments,
    required this.page,
    required this.total,
    required this.pageSize,
  });

  final List<CommentEntity> comments;
  final int page;

  // Total number of comments across all pages.
  final int total;

  // Number of items per page — used to calculate total page count.
  final int pageSize;

  int get totalPages => pageSize > 0 ? (total / pageSize).ceil() : 1;

  @override
  List<Object?> get props => [comments, page, total, pageSize];
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

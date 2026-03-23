/// Centralized endpoint paths for the comments feature.
/// All paths are relative (no leading slash, no version prefix).
class CommentEndpoints {
  const CommentEndpoints._();

  static String comments(String projectId) => 'projects/$projectId/comments';

  static String commentById(String projectId, String commentId) =>
      'projects/$projectId/comments/$commentId';
}

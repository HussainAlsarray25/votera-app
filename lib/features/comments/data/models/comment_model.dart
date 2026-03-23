import 'package:votera/features/comments/domain/entities/comment_entity.dart';

/// Data-layer representation of a comment.
/// Extends [CommentEntity] so it is usable anywhere the entity is expected,
/// and adds JSON serialization which the domain layer has no business knowing.
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.projectId,
    required super.authorId,
    required super.text,
    super.score,
    super.createdAt,
    super.updatedAt,
  });

  /// Build a [CommentModel] from the raw JSON object returned by the API.
  /// The API uses "text" for comment content and "score" for the 1–5 rating.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      authorId: (json['author_id'] ?? json['user_id'])?.toString() ?? '',
      text: json['text'] as String? ?? '',
      score: json['score'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'author_id': authorId,
      'text': text,
      'score': score,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

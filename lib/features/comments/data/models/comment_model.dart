import 'package:votera/features/comments/domain/entities/comment_entity.dart';

/// Data-layer representation of a comment.
/// Extends [CommentEntity] so it is usable anywhere the entity is expected,
/// and adds JSON serialization which the domain layer has no business knowing.
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.projectId,
    required super.authorId,
    required super.body,
    super.createdAt,
    super.updatedAt,
  });

  /// Build a [CommentModel] from the raw JSON object returned by the API.
  /// Field names mirror the CommentResponse shape: id, project_id, author_id,
  /// body, created_at, updated_at.
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      body: json['body'] as String? ?? '',
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
      'body': body,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

import 'package:equatable/equatable.dart';

/// Core business entity representing a comment on a project.
/// Contains only the fields the domain layer cares about.
/// Timestamps are nullable because the API may omit them on older records.
/// [score] is the 1–5 star rating attached to the comment (nullable for
/// backwards-compatibility with records that were created before scores
/// were introduced).
class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.text,
    this.authorName,
    this.authorAvatarUrl,
    this.score,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String text;
  /// Display name of the comment author as returned by the API.
  final String? authorName;
  /// Profile picture URL of the comment author as returned by the API.
  final String? authorAvatarUrl;
  final int? score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        authorId,
        text,
        authorName,
        authorAvatarUrl,
        score,
        createdAt,
        updatedAt,
      ];
}

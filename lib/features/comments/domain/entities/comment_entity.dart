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
    this.score,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String text;
  final int? score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        authorId,
        text,
        score,
        createdAt,
        updatedAt,
      ];
}

import 'package:equatable/equatable.dart';

/// Core business entity representing a comment on a project.
/// Contains only the fields the domain layer cares about.
/// Timestamps are nullable because the API may omit them on older records.
class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.body,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String body;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        authorId,
        body,
        createdAt,
        updatedAt,
      ];
}

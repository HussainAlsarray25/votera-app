import 'package:equatable/equatable.dart';

/// A single user's rating for a project.
class RatingEntity extends Equatable {
  const RatingEntity({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.score,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String userId;
  final int score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, projectId, userId, score, createdAt, updatedAt];
}

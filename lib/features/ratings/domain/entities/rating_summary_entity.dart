import 'package:equatable/equatable.dart';

/// Aggregated rating summary for a project.
class RatingSummaryEntity extends Equatable {
  const RatingSummaryEntity({
    required this.projectId,
    required this.averageScore,
    required this.totalRatings,
  });

  final String projectId;
  final double averageScore;
  final int totalRatings;

  @override
  List<Object?> get props => [projectId, averageScore, totalRatings];
}

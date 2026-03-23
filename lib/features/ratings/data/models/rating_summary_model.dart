import 'package:votera/features/ratings/domain/entities/rating_summary_entity.dart';

class RatingSummaryModel extends RatingSummaryEntity {
  const RatingSummaryModel({
    required super.projectId,
    required super.averageScore,
    required super.totalRatings,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    return RatingSummaryModel(
      projectId: json['project_id']?.toString() ?? '',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
    );
  }
}

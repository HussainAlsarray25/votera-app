import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';

/// Data model that maps raw API JSON to [LeaderboardEntryEntity].
/// [rank] is not in the payload and must be supplied by the caller
/// based on the entry's position in the list (1-indexed).
class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.projectId,
    required super.title,
    required super.rank,
    required super.weightedScore,
    required super.supervisorVotes,
    required super.studentVotes,
    required super.visitorVotes,
    super.coverUrl,
  });

  factory LeaderboardEntryModel.fromJson(
    Map<String, dynamic> json, {
    required int rank,
  }) {
    return LeaderboardEntryModel(
      projectId: json['project_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      rank: rank,
      weightedScore: (json['weighted_score'] as num?)?.toDouble() ?? 0.0,
      supervisorVotes: json['supervisor_votes'] as int? ?? 0,
      studentVotes: json['student_votes'] as int? ?? 0,
      visitorVotes: json['visitor_votes'] as int? ?? 0,
      coverUrl: json['cover_url'] as String?,
    );
  }
}

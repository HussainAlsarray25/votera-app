import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';

/// Data model that maps raw API JSON (snake_case) to [LeaderboardEntryEntity].
/// Extends the entity so it can be used directly wherever the entity is expected.
class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.projectId,
    required super.title,
    required super.rank,
    required super.voteCount,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      projectId: json['project_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }
}

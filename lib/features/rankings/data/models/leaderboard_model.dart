import 'package:votera/features/rankings/data/models/leaderboard_entry_model.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';

/// Data model that maps the TallyResponse JSON from GET /v1/events/{id}/votes/results
/// to [LeaderboardEntity].
///
/// Response shape:
///   { "event_id": "...", "results": [{ "project_id": "...", "weighted_score": 0.15, ... }] }
///
/// The API returns entries in descending weighted score order. Rank is derived from position.
class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.eventId,
    required super.entries,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final rawTally = json['results'] as List<dynamic>? ?? [];

    // Rank is not in the payload — derive it from the list position (1-indexed).
    final entries = rawTally.asMap().entries.map((e) {
      return LeaderboardEntryModel.fromJson(
        e.value as Map<String, dynamic>,
        rank: e.key + 1,
      );
    }).toList();

    return LeaderboardModel(
      eventId: json['event_id']?.toString() ?? '',
      entries: entries,
    );
  }
}

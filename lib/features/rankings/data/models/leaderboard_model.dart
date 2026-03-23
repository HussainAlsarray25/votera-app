import 'package:votera/features/rankings/data/models/leaderboard_entry_model.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entity.dart';

/// Data model that maps raw API JSON to [LeaderboardEntity].
/// Handles both the live leaderboard response and the final results response.
/// The only difference between the two responses is that final results include
/// a [published] boolean field.
class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.eventId,
    required super.entries,
    super.published,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'] as List<dynamic>? ?? [];

    final entries = rawEntries
        .map((e) => LeaderboardEntryModel.fromJson(
              e as Map<String, dynamic>,
            ))
        .toList();

    return LeaderboardModel(
      eventId: json['event_id']?.toString() ?? '',
      entries: entries,
      // Present only on the /leaderboard/final response.
      published: json['published'] as bool?,
    );
  }
}

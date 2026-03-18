import 'package:equatable/equatable.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';

/// The full leaderboard for a given event.
///
/// [published] is only present on final results — it will be null for
/// live (in-progress) leaderboards.
class LeaderboardEntity extends Equatable {
  const LeaderboardEntity({
    required this.eventId,
    required this.entries,
    this.published,
  });

  final String eventId;
  final List<LeaderboardEntryEntity> entries;

  /// Whether the final results have been published by the organizer.
  /// Null when this entity represents a live leaderboard, not final results.
  final bool? published;

  @override
  List<Object?> get props => [eventId, entries, published];
}

import 'package:equatable/equatable.dart';
import 'package:votera/features/rankings/domain/entities/leaderboard_entry_entity.dart';

/// The voting results for a given event, ordered by vote count descending.
class LeaderboardEntity extends Equatable {
  const LeaderboardEntity({
    required this.eventId,
    required this.entries,
  });

  final String eventId;
  final List<LeaderboardEntryEntity> entries;

  @override
  List<Object?> get props => [eventId, entries];
}

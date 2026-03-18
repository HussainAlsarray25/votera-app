import 'package:equatable/equatable.dart';

/// A single entry in a leaderboard, representing one project and its standing.
class LeaderboardEntryEntity extends Equatable {
  const LeaderboardEntryEntity({
    required this.projectId,
    required this.title,
    required this.rank,
    required this.voteCount,
  });

  final String projectId;
  final String title;

  /// The project's current position in the leaderboard, starting from 1.
  final int rank;

  final int voteCount;

  @override
  List<Object?> get props => [projectId, title, rank, voteCount];
}

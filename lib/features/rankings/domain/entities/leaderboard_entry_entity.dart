import 'package:equatable/equatable.dart';

/// A single entry in the voting results, representing one project and its standing.
/// Rank is derived from the entry's position in the API response (1-indexed).
class LeaderboardEntryEntity extends Equatable {
  const LeaderboardEntryEntity({
    required this.projectId,
    required this.title,
    required this.rank,
    required this.weightedScore,
    required this.supervisorVotes,
    required this.studentVotes,
    required this.visitorVotes,
    this.coverUrl,
  });

  final String projectId;
  final String title;

  /// Position in the results list, starting from 1.
  final int rank;

  /// Weighted score used to determine overall ranking.
  final double weightedScore;

  final int supervisorVotes;
  final int studentVotes;
  final int visitorVotes;

  /// Cover image URL, may be null if the project has no cover.
  final String? coverUrl;

  /// Total raw votes across all tracks.
  int get totalVotes => supervisorVotes + studentVotes + visitorVotes;

  @override
  List<Object?> get props => [
        projectId,
        title,
        rank,
        weightedScore,
        supervisorVotes,
        studentVotes,
        visitorVotes,
        coverUrl,
      ];
}

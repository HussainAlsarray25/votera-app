/// Represents the vote track filter supported by the leaderboard endpoint.
/// Maps to the `track` query parameter: all | community | supervisor.
enum LeaderboardTrack { all, community, supervisor }

extension LeaderboardTrackX on LeaderboardTrack {
  String toQueryValue() {
    switch (this) {
      case LeaderboardTrack.community:
        return 'community';
      case LeaderboardTrack.supervisor:
        return 'supervisor';
      case LeaderboardTrack.all:
        return 'all';
    }
  }
}

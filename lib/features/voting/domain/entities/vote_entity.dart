import 'package:equatable/equatable.dart';

/// The voting track, distinguishing supervisor votes from community votes.
enum VoteTrack {
  supervisor,
  community,
}

/// Parses a vote track string from the API into [VoteTrack].
/// Returns null when the value is unrecognised.
VoteTrack? voteTrackFromString(String? value) {
  switch (value) {
    case 'supervisor':
      return VoteTrack.supervisor;
    case 'community':
      return VoteTrack.community;
    default:
      return null;
  }
}

class VoteEntity extends Equatable {
  const VoteEntity({
    required this.id,
    required this.eventId,
    required this.projectId,
    required this.voterId,
    this.track,
    this.createdAt,
  });

  final String id;
  final String eventId;
  final String projectId;
  final String voterId;
  final VoteTrack? track;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, eventId, projectId, voterId, track, createdAt];
}

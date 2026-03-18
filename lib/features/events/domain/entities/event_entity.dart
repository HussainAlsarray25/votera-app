import 'package:equatable/equatable.dart';

/// The lifecycle status of an event, as defined by the API.
enum EventStatus {
  draft,
  open,
  voting,
  closed,
  archived,
}

/// Parses an event status string from the API into the [EventStatus] enum.
/// Returns null if the value is unrecognised.
EventStatus? eventStatusFromString(String? value) {
  switch (value) {
    case 'draft':
      return EventStatus.draft;
    case 'open':
      return EventStatus.open;
    case 'voting':
      return EventStatus.voting;
    case 'closed':
      return EventStatus.closed;
    case 'archived':
      return EventStatus.archived;
    default:
      return null;
  }
}

/// Core business entity for an event.
/// All date fields are nullable because the API may omit them for drafts.
class EventEntity extends Equatable {
  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.organizerId,
    required this.createdAt,
    required this.updatedAt,
    this.startAt,
    this.endAt,
    this.votingStart,
    this.votingEnd,
    this.maxCommunityVotes,
    this.maxSupervisorVotes,
    this.minTeamSize,
    this.maxTeamSize,
  });

  final String id;
  final String title;
  final String description;
  final EventStatus status;
  final String organizerId;

  /// When the event window opens for participants.
  final DateTime? startAt;

  /// When the event window closes for participants.
  final DateTime? endAt;

  /// When voting becomes available.
  final DateTime? votingStart;

  /// When voting closes.
  final DateTime? votingEnd;

  /// Maximum community-track votes a user may cast. Null means unlimited.
  final int? maxCommunityVotes;

  /// Maximum supervisor-track votes a user may cast. Null means unlimited.
  final int? maxSupervisorVotes;

  /// Minimum number of members required per team.
  final int? minTeamSize;

  /// Maximum number of members allowed per team.
  final int? maxTeamSize;

  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        organizerId,
        startAt,
        endAt,
        votingStart,
        votingEnd,
        maxCommunityVotes,
        maxSupervisorVotes,
        minTeamSize,
        maxTeamSize,
        createdAt,
        updatedAt,
      ];
}

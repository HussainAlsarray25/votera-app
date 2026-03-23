import 'package:votera/features/events/domain/entities/event_entity.dart';

/// Data model that maps the raw API JSON (snake_case) to [EventEntity].
/// Extends the entity so it can be used directly anywhere an entity is expected.
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.organizerId,
    required super.createdAt,
    required super.updatedAt,
    super.startAt,
    super.endAt,
    super.votingStart,
    super.votingEnd,
    super.maxCommunityVotes,
    super.maxSupervisorVotes,
    super.minTeamSize,
    super.maxTeamSize,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: eventStatusFromString(json['status'] as String?) ??
          EventStatus.draft,
      organizerId: json['organizer_id'] as String,
      startAt: _parseDate(json['start_at']),
      endAt: _parseDate(json['end_at']),
      votingStart: _parseDate(json['voting_start']),
      votingEnd: _parseDate(json['voting_end']),
      maxCommunityVotes: json['max_community_votes'] as int?,
      maxSupervisorVotes: json['max_supervisor_votes'] as int?,
      minTeamSize: json['min_team_size'] as int?,
      maxTeamSize: json['max_team_size'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Safely parses an ISO-8601 date string. Returns null if the value
  /// is absent or not a valid string, rather than throwing.
  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}

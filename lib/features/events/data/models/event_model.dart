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
    super.latitude,
    super.longitude,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      // Some API responses omit or null-out fields; guard each cast to
      // prevent a type-cast failure from crashing the whole screen.
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: eventStatusFromString(json['status'] as String?) ??
          EventStatus.draft,
      organizerId: json['organizer_id']?.toString() ?? '',
      startAt: _parseDate(json['start_at']),
      endAt: _parseDate(json['end_at']),
      votingStart: _parseDate(json['voting_start']),
      votingEnd: _parseDate(json['voting_end']),
      maxCommunityVotes: json['max_community_votes'] as int?,
      maxSupervisorVotes: json['max_supervisor_votes'] as int?,
      minTeamSize: json['min_team_size'] as int?,
      maxTeamSize: json['max_team_size'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  /// Safely parses an ISO-8601 date string. Returns null if the value
  /// is absent or not a valid string, rather than throwing.
  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}

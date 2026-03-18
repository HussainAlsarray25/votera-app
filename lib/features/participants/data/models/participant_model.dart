import 'package:votera/features/participants/domain/entities/participant_entity.dart';

/// Data-layer model that maps the raw API JSON to [ApplicationEntity].
/// Inherits all domain fields from the entity so repositories can return
/// this directly without any extra conversion step.
class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.eventId,
    required super.teamId,
    required super.status,
    required super.attempt,
    super.rejectionNote,
    super.appliedAt,
    super.reviewedAt,
    super.reviewedBy,
  });

  /// Parses an application from the API's snake_case JSON response.
  /// [status] defaults to [ApplicationStatus.pending] when the value is
  /// missing or unrecognised, which matches the server's default behaviour.
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      status: applicationStatusFromString(json['status'] as String?) ??
          ApplicationStatus.pending,
      attempt: json['attempt'] as int? ?? 1,
      rejectionNote: json['rejection_note'] as String?,
      appliedAt: json['applied_at'] != null
          ? DateTime.tryParse(json['applied_at'].toString())
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'].toString())
          : null,
      reviewedBy: json['reviewed_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'team_id': teamId,
      'status': status.name,
      'attempt': attempt,
      'rejection_note': rejectionNote,
      'applied_at': appliedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
    };
  }
}

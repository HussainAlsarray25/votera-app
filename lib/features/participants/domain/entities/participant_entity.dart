import 'package:equatable/equatable.dart';

/// The review status of an application, as defined by the API.
enum ApplicationStatus {
  pending,
  approved,
  rejected,
}

/// Parses an application status string from the API into [ApplicationStatus].
/// Returns null when the value is unrecognised so callers can handle it
/// gracefully rather than throwing.
ApplicationStatus? applicationStatusFromString(String? value) {
  switch (value) {
    case 'pending':
      return ApplicationStatus.pending;
    case 'approved':
      return ApplicationStatus.approved;
    case 'rejected':
      return ApplicationStatus.rejected;
    default:
      return null;
  }
}

/// Core business entity representing a team's application to an event.
/// [reviewedAt] and [reviewedBy] are nullable because they are only populated
/// after an organiser acts on the application.
class ApplicationEntity extends Equatable {
  const ApplicationEntity({
    required this.id,
    required this.eventId,
    required this.teamId,
    required this.status,
    required this.attempt,
    this.rejectionNote,
    this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  final String id;
  final String eventId;
  final String teamId;
  final ApplicationStatus status;
  final int attempt;
  final String? rejectionNote;
  final DateTime? appliedAt;

  /// When the organiser reviewed the application. Null until reviewed.
  final DateTime? reviewedAt;

  /// ID of the user who reviewed the application. Null until reviewed.
  final String? reviewedBy;

  @override
  List<Object?> get props => [
        id,
        eventId,
        teamId,
        status,
        attempt,
        rejectionNote,
        appliedAt,
        reviewedAt,
        reviewedBy,
      ];
}

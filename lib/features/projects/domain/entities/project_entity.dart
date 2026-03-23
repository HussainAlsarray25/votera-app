import 'package:equatable/equatable.dart';
import 'package:votera/features/projects/domain/entities/project_media_entity.dart';

/// Lifecycle status of a project submission.
enum ProjectStatus {
  draft,
  submitted,
  accepted,
  rejected,
}

/// Converts a raw string from the API into a [ProjectStatus] value.
/// Defaults to [ProjectStatus.draft] for any unrecognized value.
ProjectStatus projectStatusFromString(String? value) {
  switch (value) {
    case 'submitted':
      return ProjectStatus.submitted;
    case 'accepted':
      return ProjectStatus.accepted;
    case 'rejected':
      return ProjectStatus.rejected;
    case 'draft':
    default:
      return ProjectStatus.draft;
  }
}

/// Core domain entity representing a team's project in an event.
class ProjectEntity extends Equatable {
  const ProjectEntity({
    required this.id,
    required this.eventId,
    required this.teamId,
    required this.title,
    required this.status,
    required this.media,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.repoUrl,
    this.demoUrl,
    this.techStack,
    this.barcodeToken,
  });

  final String id;
  final String eventId;
  final String teamId;
  final String title;

  /// Optional long-form description of the project.
  final String? description;

  /// Link to the source code repository.
  final String? repoUrl;

  /// Link to a live demo or deployed version.
  final String? demoUrl;

  /// Technologies and frameworks used in the project (free-form string).
  final String? techStack;

  final ProjectStatus status;

  /// All media files attached to this project.
  final List<ProjectMediaEntity> media;

  /// QR scan token for looking up this project.
  final String? barcodeToken;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        eventId,
        teamId,
        title,
        description,
        repoUrl,
        demoUrl,
        techStack,
        status,
        media,
        barcodeToken,
        createdAt,
        updatedAt,
      ];
}

import 'package:votera/features/projects/data/models/project_media_model.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';

/// Data model for [ProjectEntity]. Handles JSON deserialization
/// from the snake_case API response.
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.eventId,
    required super.teamId,
    required super.title,
    required super.status,
    required super.media,
    super.createdAt,
    super.updatedAt,
    super.description,
    super.repoUrl,
    super.demoUrl,
    super.techStack,
    super.barcodeToken,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // Unwrap the API envelope { success, message, data: {...} } when present.
    // Single-object endpoints return the envelope directly; list endpoints
    // (via PaginatedResponse) pass the inner item already unwrapped.
    final payload =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final rawMedia = payload['media'] as List<dynamic>? ?? [];

    return ProjectModel(
      id: payload['id']?.toString() ?? '',
      eventId: payload['event_id']?.toString() ?? '',
      teamId: payload['team_id']?.toString() ?? '',
      title: payload['title'] as String? ?? '',
      description: payload['description'] as String?,
      repoUrl: payload['repo_url'] as String?,
      demoUrl: payload['demo_url'] as String?,
      techStack: payload['tech_stack'] as String?,
      barcodeToken: payload['barcode_token'] as String?,
      status: projectStatusFromString(payload['status'] as String?),
      media: rawMedia
          .map((e) => ProjectMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: payload['created_at'] != null
          ? DateTime.tryParse(payload['created_at'].toString())
          : null,
      updatedAt: payload['updated_at'] != null
          ? DateTime.tryParse(payload['updated_at'].toString())
          : null,
    );
  }
}

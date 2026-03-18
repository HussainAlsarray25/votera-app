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
    super.barcodeToken,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>? ?? [];

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      repoUrl: json['repo_url'] as String?,
      demoUrl: json['demo_url'] as String?,
      barcodeToken: json['barcode_token'] as String?,
      status: projectStatusFromString(json['status'] as String?),
      media: rawMedia
          .map((e) => ProjectMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

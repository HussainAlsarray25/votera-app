import 'package:votera/features/projects/domain/entities/project_media_entity.dart';

/// Data model for [ProjectMediaEntity]. Handles JSON deserialization
/// from the snake_case API response.
class ProjectMediaModel extends ProjectMediaEntity {
  const ProjectMediaModel({
    required super.id,
    required super.projectId,
    required super.url,
    required super.fileKey,
    required super.fileType,
    super.createdAt,
  });

  factory ProjectMediaModel.fromJson(Map<String, dynamic> json) {
    return ProjectMediaModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      url: json['url'] as String? ?? '',
      fileKey: json['file_key'] as String? ?? '',
      fileType: json['file_type'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

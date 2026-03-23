import 'package:equatable/equatable.dart';

/// Represents a single media attachment on a project.
class ProjectMediaEntity extends Equatable {
  const ProjectMediaEntity({
    required this.id,
    required this.projectId,
    required this.url,
    required this.fileKey,
    required this.fileType,
    this.createdAt,
  });

  final String id;
  final String projectId;

  /// The public URL used to display the media.
  final String url;

  /// The storage key used to reference or delete the file.
  final String fileKey;

  /// MIME type or file extension (e.g. "image/png").
  final String fileType;

  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, projectId, url, fileKey, fileType, createdAt];
}

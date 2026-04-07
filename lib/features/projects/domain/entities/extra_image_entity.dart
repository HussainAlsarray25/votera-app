import 'package:equatable/equatable.dart';

/// Represents a single extra image attached to a project.
/// Each image has an [id] that can be used to delete it individually.
class ExtraImageEntity extends Equatable {
  const ExtraImageEntity({
    required this.id,
    required this.url,
  });

  final String id;

  /// The public URL used to display the image.
  final String url;

  @override
  List<Object?> get props => [id, url];
}

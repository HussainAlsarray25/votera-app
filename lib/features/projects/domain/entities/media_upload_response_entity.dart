import 'package:equatable/equatable.dart';

/// Returned by both cover and extra-image upload endpoints.
/// The [id] is used to delete the image later; the [url] is for display.
class MediaUploadResponseEntity extends Equatable {
  const MediaUploadResponseEntity({
    required this.id,
    required this.url,
  });

  final String id;
  final String url;

  @override
  List<Object?> get props => [id, url];
}

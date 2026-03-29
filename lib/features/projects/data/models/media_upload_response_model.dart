import 'package:votera/features/projects/domain/entities/media_upload_response_entity.dart';

/// Data model for [MediaUploadResponseEntity]. Handles JSON deserialization
/// from the cover and extra-image upload endpoint responses.
class MediaUploadResponseModel extends MediaUploadResponseEntity {
  const MediaUploadResponseModel({
    required super.id,
    required super.url,
  });

  factory MediaUploadResponseModel.fromJson(Map<String, dynamic> json) {
    // Unwrap the API envelope { success, message, data: {...} } when
    // present.
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return MediaUploadResponseModel(
      id: payload['id']?.toString() ?? '',
      url: payload['url'] as String? ?? '',
    );
  }
}

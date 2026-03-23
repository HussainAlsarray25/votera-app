import 'package:votera/features/projects/domain/entities/upload_url_entity.dart';

/// Data model for [UploadUrlEntity]. Handles JSON deserialization
/// from the upload-url endpoint response.
class UploadUrlModel extends UploadUrlEntity {
  const UploadUrlModel({
    required super.uploadUrl,
    required super.publicUrl,
  });

  factory UploadUrlModel.fromJson(Map<String, dynamic> json) {
    return UploadUrlModel(
      uploadUrl: json['upload_url'] as String? ?? '',
      publicUrl: json['public_url'] as String? ?? '',
    );
  }
}

import 'package:votera/features/certifications/domain/entities/upload_url_entity.dart';

class CertificationUploadUrlModel extends CertificationUploadUrlEntity {
  const CertificationUploadUrlModel({
    required super.uploadUrl,
    required super.publicUrl,
  });

  factory CertificationUploadUrlModel.fromJson(Map<String, dynamic> json) {
    return CertificationUploadUrlModel(
      uploadUrl: json['upload_url'] as String? ?? '',
      publicUrl: json['public_url'] as String? ?? '',
    );
  }
}

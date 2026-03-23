import 'package:equatable/equatable.dart';

/// Holds the pre-signed upload URL and the resulting public URL
/// for certification document uploads.
class CertificationUploadUrlEntity extends Equatable {
  const CertificationUploadUrlEntity({
    required this.uploadUrl,
    required this.publicUrl,
  });

  final String uploadUrl;
  final String publicUrl;

  @override
  List<Object?> get props => [uploadUrl, publicUrl];
}

import 'package:equatable/equatable.dart';

/// Holds the pre-signed upload URL and the resulting public URL
/// returned when requesting a media upload slot.
class UploadUrlEntity extends Equatable {
  const UploadUrlEntity({
    required this.uploadUrl,
    required this.publicUrl,
  });

  /// Pre-signed URL to use for the direct file upload (e.g. PUT to S3).
  final String uploadUrl;

  /// The publicly accessible URL of the file once the upload completes.
  final String publicUrl;

  @override
  List<Object?> get props => [uploadUrl, publicUrl];
}

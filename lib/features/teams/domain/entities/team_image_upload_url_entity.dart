import 'package:equatable/equatable.dart';

/// Holds the presigned S3 URL for uploading a team image and the resulting public URL.
class TeamImageUploadUrlEntity extends Equatable {
  const TeamImageUploadUrlEntity({
    required this.uploadUrl,
    required this.publicUrl,
  });

  // PUT requests should be made to this URL to upload the image file.
  final String uploadUrl;

  // The publicly accessible URL where the image will be available after upload.
  final String publicUrl;

  @override
  List<Object?> get props => [uploadUrl, publicUrl];
}

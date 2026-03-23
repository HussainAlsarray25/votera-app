import 'package:equatable/equatable.dart';

/// Represents a participant verification request submitted by the user.
/// The [status] field is one of: pending, approved, rejected.
class ParticipantRequest extends Equatable {
  const ParticipantRequest({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.universityId,
    required this.department,
    required this.stage,
    required this.documentUrl,
    required this.status,
    required this.type,
    required this.createdAt,
    this.reviewNote,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String universityId;
  final String department;
  final String stage;
  final String documentUrl;
  final String status;
  final String type;
  final String createdAt;
  final String? reviewNote;
  final String? reviewedBy;
  final String? reviewedAt;

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
        id, userId, fullName, universityId, department, stage,
        documentUrl, status, type, createdAt, reviewNote, reviewedBy, reviewedAt,
      ];
}

/// Holds the two URLs returned by the presigned-upload endpoint.
class UidUploadUrls extends Equatable {
  const UidUploadUrls({required this.uploadUrl, required this.publicUrl});

  final String uploadUrl;
  final String publicUrl;

  @override
  List<Object?> get props => [uploadUrl, publicUrl];
}

import 'package:equatable/equatable.dart';

/// Type of certification request.
enum CertificationType {
  participant,
  supervisor,
}

/// Parses a certification type string from the API.
CertificationType? certificationTypeFromString(String? value) {
  switch (value) {
    case 'participant':
      return CertificationType.participant;
    case 'supervisor':
      return CertificationType.supervisor;
    default:
      return null;
  }
}

/// Review status of a certification request.
enum CertificationStatus {
  pending,
  approved,
  rejected,
}

/// Parses a certification status string from the API.
CertificationStatus? certificationStatusFromString(String? value) {
  switch (value) {
    case 'pending':
      return CertificationStatus.pending;
    case 'approved':
      return CertificationStatus.approved;
    case 'rejected':
      return CertificationStatus.rejected;
    default:
      return null;
  }
}

/// Core business entity for a certification request.
class CertificationEntity extends Equatable {
  const CertificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.documentUrl,
    this.rejectionNote,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  final String id;
  final String userId;
  final CertificationType type;
  final CertificationStatus status;
  final String documentUrl;
  final String? rejectionNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        status,
        documentUrl,
        rejectionNote,
        submittedAt,
        reviewedAt,
        reviewedBy,
      ];
}

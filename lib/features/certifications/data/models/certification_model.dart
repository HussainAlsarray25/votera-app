import 'package:votera/features/certifications/domain/entities/certification_entity.dart';

class CertificationModel extends CertificationEntity {
  const CertificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.status,
    required super.documentUrl,
    super.rejectionNote,
    super.submittedAt,
    super.reviewedAt,
    super.reviewedBy,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      type: certificationTypeFromString(json['type'] as String?) ??
          CertificationType.participant,
      status: certificationStatusFromString(json['status'] as String?) ??
          CertificationStatus.pending,
      documentUrl: json['document_url'] as String? ?? '',
      rejectionNote: json['rejection_note'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'].toString())
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'].toString())
          : null,
      reviewedBy: json['reviewed_by']?.toString(),
    );
  }
}

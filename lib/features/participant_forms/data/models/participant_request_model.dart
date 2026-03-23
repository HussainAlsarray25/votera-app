import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';

/// Data model that extends the domain entity.
/// Responsible for deserializing API responses into domain objects.
class ParticipantRequestModel extends ParticipantRequest {
  const ParticipantRequestModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.universityId,
    required super.department,
    required super.stage,
    required super.documentUrl,
    required super.status,
    required super.type,
    required super.createdAt,
    super.reviewNote,
    super.reviewedBy,
    super.reviewedAt,
  });

  factory ParticipantRequestModel.fromJson(Map<String, dynamic> json) {
    return ParticipantRequestModel(
      id:           json['id'] as String? ?? '',
      userId:       json['user_id'] as String? ?? '',
      fullName:     json['full_name'] as String? ?? '',
      universityId: json['university_id'] as String? ?? '',
      department:   json['department'] as String? ?? '',
      stage:        json['stage'] as String? ?? '',
      documentUrl:  json['document_url'] as String? ?? '',
      status:       json['status'] as String? ?? 'pending',
      type:         json['type'] as String? ?? '',
      createdAt:    json['created_at'] as String? ?? '',
      reviewNote:   json['review_note'] as String?,
      reviewedBy:   json['reviewed_by'] as String?,
      reviewedAt:   json['reviewed_at'] as String?,
    );
  }
}

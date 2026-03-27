import 'package:votera/features/teams/domain/entities/join_request_entity.dart';

class JoinRequestModel extends JoinRequestEntity {
  const JoinRequestModel({
    required super.id,
    required super.teamId,
    required super.userId,
    required super.status,
    super.message,
    super.createdAt,
    super.respondedAt,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestModel(
      id: json['id']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: joinRequestStatusFromString(json['status'] as String?) ??
          JoinRequestStatus.pending,
      message: json['message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'].toString())
          : null,
    );
  }
}

import 'package:votera/features/teams/domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  const InvitationModel({
    required super.id,
    required super.teamId,
    required super.inviteeId,
    required super.invitedBy,
    required super.status,
    super.createdAt,
    super.respondedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      inviteeId: json['invitee_id']?.toString() ?? '',
      invitedBy: json['invited_by']?.toString() ?? '',
      status: invitationStatusFromString(json['status'] as String?) ??
          InvitationStatus.pending,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'].toString())
          : null,
    );
  }
}

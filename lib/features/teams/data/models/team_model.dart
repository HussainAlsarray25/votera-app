import 'package:votera/features/teams/data/models/team_member_model.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.leaderId,
    required super.members,
    super.handle,
    super.description,
    super.imageUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    // Unwrap the API envelope { success, message, data: {...} } when present.
    final payload =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final rawMembers = payload['members'] as List<dynamic>? ?? [];
    return TeamModel(
      id: payload['id']?.toString() ?? '',
      name: payload['name'] as String? ?? '',
      handle: payload['handle'] as String?,
      description: payload['description'] as String?,
      imageUrl: payload['image_url'] as String?,
      leaderId: payload['leader_id']?.toString() ?? '',
      members: rawMembers
          .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: payload['created_at'] != null
          ? DateTime.tryParse(payload['created_at'].toString())
          : null,
      updatedAt: payload['updated_at'] != null
          ? DateTime.tryParse(payload['updated_at'].toString())
          : null,
    );
  }
}

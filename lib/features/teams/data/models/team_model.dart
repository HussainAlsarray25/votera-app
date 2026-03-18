import 'package:votera/features/teams/data/models/team_member_model.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';

class TeamModel extends TeamEntity {
  const TeamModel({
    required super.id,
    required super.name,
    required super.leaderId,
    required super.members,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    return TeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      leaderId: json['leader_id']?.toString() ?? '',
      members: rawMembers
          .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

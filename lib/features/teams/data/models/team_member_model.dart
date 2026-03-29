import 'package:votera/features/teams/domain/entities/team_member_entity.dart';

class TeamMemberModel extends TeamMemberEntity {
  const TeamMemberModel({
    required super.userId,
    super.fullName,
    super.email,
    super.joinedAt,
    super.profilePictureUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
      profilePictureUrl: json['profile_picture_url']?.toString(),
    );
  }
}

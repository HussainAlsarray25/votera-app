import 'package:equatable/equatable.dart';
import 'package:votera/features/teams/domain/entities/team_member_entity.dart';

/// Core business entity representing a team.
class TeamEntity extends Equatable {
  const TeamEntity({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.members,
    this.handle,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? handle;
  final String? description;

  // Public URL of the team's avatar image, or null if none has been uploaded.
  final String? imageUrl;
  final String leaderId;
  final List<TeamMemberEntity> members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        handle,
        description,
        imageUrl,
        leaderId,
        members,
        createdAt,
        updatedAt,
      ];
}

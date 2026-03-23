import 'package:equatable/equatable.dart';

/// Represents a single member within a team.
class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.userId,
    this.joinedAt,
  });

  final String userId;
  final DateTime? joinedAt;

  @override
  List<Object?> get props => [userId, joinedAt];
}

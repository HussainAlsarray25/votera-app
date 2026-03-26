import 'package:equatable/equatable.dart';

/// Represents a single member within a team.
class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.userId,
    this.fullName,
    this.email,
    this.joinedAt,
  });

  final String userId;
  final String? fullName;
  final String? email;
  final DateTime? joinedAt;

  /// Display name — prefers fullName, falls back to userId.
  String get displayName => fullName?.isNotEmpty == true ? fullName! : userId;

  @override
  List<Object?> get props => [userId, fullName, email, joinedAt];
}

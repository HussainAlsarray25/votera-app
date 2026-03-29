import 'package:equatable/equatable.dart';

/// Represents a single member within a team.
class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.userId,
    this.fullName,
    this.email,
    this.joinedAt,
    this.profilePictureUrl,
  });

  final String userId;
  final String? fullName;
  final String? email;
  final DateTime? joinedAt;
  // Remote URL of the member's profile picture. Null when not in API response.
  final String? profilePictureUrl;

  /// Display name — prefers fullName, falls back to userId.
  String get displayName =>
      fullName != null && fullName!.isNotEmpty ? fullName! : userId;

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        joinedAt,
        profilePictureUrl,
      ];
}

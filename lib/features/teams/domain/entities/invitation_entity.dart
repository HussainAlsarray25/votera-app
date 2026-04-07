import 'package:equatable/equatable.dart';

/// Status of a team invitation.
enum InvitationStatus {
  pending,
  accepted,
  declined,
}

/// Parses an invitation status string from the API.
InvitationStatus? invitationStatusFromString(String? value) {
  switch (value) {
    case 'pending':
      return InvitationStatus.pending;
    case 'accepted':
      return InvitationStatus.accepted;
    case 'declined':
      return InvitationStatus.declined;
    default:
      return null;
  }
}

/// Represents an invitation to join a team.
class InvitationEntity extends Equatable {
  const InvitationEntity({
    required this.id,
    required this.teamId,
    required this.inviteeId,
    required this.invitedBy,
    required this.status,
    this.teamName,
    this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String teamId;

  // Human-readable team name returned by the API alongside the team ID.
  final String? teamName;
  final String inviteeId;
  final String invitedBy;
  final InvitationStatus status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  @override
  List<Object?> get props => [
        id,
        teamId,
        teamName,
        inviteeId,
        invitedBy,
        status,
        createdAt,
        respondedAt,
      ];
}

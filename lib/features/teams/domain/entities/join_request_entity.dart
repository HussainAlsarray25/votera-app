import 'package:equatable/equatable.dart';

enum JoinRequestStatus { pending, approved, declined }

JoinRequestStatus? joinRequestStatusFromString(String? value) {
  switch (value) {
    case 'pending':
      return JoinRequestStatus.pending;
    case 'approved':
      return JoinRequestStatus.approved;
    case 'declined':
      return JoinRequestStatus.declined;
    default:
      return null;
  }
}

/// Represents a request from a user to join a team.
class JoinRequestEntity extends Equatable {
  const JoinRequestEntity({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.status,
    this.message,
    this.createdAt,
    this.respondedAt,
  });

  final String id;
  final String teamId;
  final String userId;
  final JoinRequestStatus status;

  // Optional message the requester included when sending the request.
  final String? message;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  @override
  List<Object?> get props => [
        id,
        teamId,
        userId,
        status,
        message,
        createdAt,
        respondedAt,
      ];
}

import 'package:votera/features/voting/domain/entities/vote_entity.dart';

class VoteModel extends VoteEntity {
  const VoteModel({
    required super.id,
    required super.eventId,
    required super.projectId,
    required super.voterId,
    super.track,
    super.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      voterId: json['voter_id']?.toString() ?? '',
      track: voteTrackFromString(json['track'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

import 'package:votera/features/voting/domain/entities/project_tally_entity.dart';
import 'package:votera/features/voting/domain/entities/tally_entity.dart';

class ProjectTallyModel extends ProjectTallyEntity {
  const ProjectTallyModel({
    required super.projectId,
    required super.voteCount,
  });

  factory ProjectTallyModel.fromJson(Map<String, dynamic> json) {
    return ProjectTallyModel(
      projectId: json['project_id']?.toString() ?? '',
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }
}

class TallyModel extends TallyEntity {
  const TallyModel({
    required super.eventId,
    required super.tally,
  });

  factory TallyModel.fromJson(Map<String, dynamic> json) {
    final rawTally = json['tally'] as List<dynamic>? ?? [];
    final tally = rawTally
        .map((e) => ProjectTallyModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TallyModel(
      eventId: json['event_id']?.toString() ?? '',
      tally: tally,
    );
  }
}

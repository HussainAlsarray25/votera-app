import 'package:equatable/equatable.dart';

class ProjectTallyEntity extends Equatable {
  const ProjectTallyEntity({
    required this.projectId,
    required this.voteCount,
  });

  final String projectId;
  final int voteCount;

  @override
  List<Object?> get props => [projectId, voteCount];
}

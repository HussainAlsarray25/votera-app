import 'package:equatable/equatable.dart';
import 'package:votera/features/voting/domain/entities/project_tally_entity.dart';

class TallyEntity extends Equatable {
  const TallyEntity({
    required this.eventId,
    required this.tally,
  });

  final String eventId;
  final List<ProjectTallyEntity> tally;

  @override
  List<Object?> get props => [eventId, tally];
}

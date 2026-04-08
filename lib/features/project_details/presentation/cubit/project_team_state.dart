part of 'project_team_cubit.dart';

abstract class ProjectTeamState extends Equatable {
  const ProjectTeamState();

  @override
  List<Object?> get props => [];
}

class ProjectTeamInitial extends ProjectTeamState {
  const ProjectTeamInitial();
}

class ProjectTeamLoading extends ProjectTeamState {
  const ProjectTeamLoading();
}

class ProjectTeamLoaded extends ProjectTeamState {
  const ProjectTeamLoaded({required this.team});

  final TeamEntity team;

  @override
  List<Object?> get props => [team];
}

class ProjectTeamError extends ProjectTeamState {
  const ProjectTeamError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/teams/domain/entities/team_entity.dart';
import 'package:votera/features/teams/domain/usecases/get_team.dart';

part 'project_team_state.dart';

/// Loads and exposes the team associated with a project.
class ProjectTeamCubit extends Cubit<ProjectTeamState> {
  ProjectTeamCubit({required this.getTeam}) : super(const ProjectTeamInitial());

  final GetTeam getTeam;

  Future<void> loadTeam(String teamId) async {
    emit(const ProjectTeamLoading());
    final result = await getTeam(GetTeamParams(teamId: teamId));
    result.fold(
      (failure) => emit(ProjectTeamError(message: failure.message)),
      (team) => emit(ProjectTeamLoaded(team: team)),
    );
  }
}
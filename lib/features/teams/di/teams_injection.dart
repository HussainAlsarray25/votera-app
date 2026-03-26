import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/teams/data/datasources/remote/team_remote_data_source.dart';
import 'package:votera/features/teams/data/repositories/team_repository_impl.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';
import 'package:votera/features/teams/domain/usecases/cancel_invitation.dart';
import 'package:votera/features/teams/domain/usecases/create_team.dart';
import 'package:votera/features/teams/domain/usecases/delete_team.dart';
import 'package:votera/features/teams/domain/usecases/get_my_invitations.dart';
import 'package:votera/features/teams/domain/usecases/get_my_team.dart';
import 'package:votera/features/teams/domain/usecases/get_team.dart';
import 'package:votera/features/teams/domain/usecases/invite_member.dart';
import 'package:votera/features/teams/domain/usecases/leave_team.dart';
import 'package:votera/features/teams/domain/usecases/remove_member.dart';
import 'package:votera/features/teams/domain/usecases/respond_to_invitation.dart';
import 'package:votera/features/teams/domain/usecases/search_teams.dart' show ListTeams;
import 'package:votera/features/teams/domain/usecases/transfer_leadership.dart';
import 'package:votera/features/teams/domain/usecases/update_team.dart';
import 'package:votera/features/teams/presentation/cubit/teams_cubit.dart';

/// Teams feature dependency registration.
void initTeamsFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<TeamsCubit>(
      () => TeamsCubit(
        createTeam: sl<CreateTeam>(),
        getTeam: sl<GetTeam>(),
        getMyTeam: sl<GetMyTeam>(),
        updateTeam: sl<UpdateTeam>(),
        deleteTeam: sl<DeleteTeam>(),
        inviteMember: sl<InviteMember>(),
        getMyInvitations: sl<GetMyInvitations>(),
        respondToInvitation: sl<RespondToInvitation>(),
        leaveTeam: sl<LeaveTeam>(),
        removeMember: sl<RemoveMember>(),
        transferLeadership: sl<TransferLeadership>(),
        listTeams: sl<ListTeams>(),
        cancelInvitation: sl<CancelInvitation>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<CreateTeam>(
      () => CreateTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<GetTeam>(
      () => GetTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<GetMyTeam>(
      () => GetMyTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<UpdateTeam>(
      () => UpdateTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<DeleteTeam>(
      () => DeleteTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<InviteMember>(
      () => InviteMember(sl<TeamRepository>()),
    )
    ..registerLazySingleton<GetMyInvitations>(
      () => GetMyInvitations(sl<TeamRepository>()),
    )
    ..registerLazySingleton<RespondToInvitation>(
      () => RespondToInvitation(sl<TeamRepository>()),
    )
    ..registerLazySingleton<LeaveTeam>(
      () => LeaveTeam(sl<TeamRepository>()),
    )
    ..registerLazySingleton<RemoveMember>(
      () => RemoveMember(sl<TeamRepository>()),
    )
    ..registerLazySingleton<TransferLeadership>(
      () => TransferLeadership(sl<TeamRepository>()),
    )
    ..registerLazySingleton<ListTeams>(
      () => ListTeams(sl<TeamRepository>()),
    )
    ..registerLazySingleton<CancelInvitation>(
      () => CancelInvitation(sl<TeamRepository>()),
    )
    // Repositories
    ..registerLazySingleton<TeamRepository>(
      () => TeamRepositoryImpl(
        remote: sl<TeamRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<TeamRemoteDataSource>(
      () => TeamRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/voting/data/datasources/remote/voting_remote_data_source.dart';
import 'package:votera/features/voting/data/repositories/voting_repository_impl.dart';
import 'package:votera/features/voting/domain/repositories/voting_repository.dart';
import 'package:votera/features/voting/domain/usecases/cast_vote.dart';
import 'package:votera/features/voting/domain/usecases/get_event_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_my_votes.dart';
import 'package:votera/features/voting/domain/usecases/get_vote_tally.dart';
import 'package:votera/features/voting/domain/usecases/retract_vote.dart';
import 'package:votera/features/voting/presentation/cubit/voting_cubit.dart';

void initVotingFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<VotingCubit>(
      () => VotingCubit(
        castVote: sl<CastVote>(),
        getMyVotes: sl<GetMyVotes>(),
        getVoteTally: sl<GetVoteTally>(),
        retractVote: sl<RetractVote>(),
        getEventVotes: sl<GetEventVotes>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<CastVote>(
      () => CastVote(sl<VotingRepository>()),
    )
    ..registerLazySingleton<GetMyVotes>(
      () => GetMyVotes(sl<VotingRepository>()),
    )
    ..registerLazySingleton<GetVoteTally>(
      () => GetVoteTally(sl<VotingRepository>()),
    )
    ..registerLazySingleton<RetractVote>(
      () => RetractVote(sl<VotingRepository>()),
    )
    ..registerLazySingleton<GetEventVotes>(
      () => GetEventVotes(sl<VotingRepository>()),
    )
    // Repositories
    ..registerLazySingleton<VotingRepository>(
      () => VotingRepositoryImpl(
        remoteDataSource: sl<VotingRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<VotingRemoteDataSource>(
      () => VotingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

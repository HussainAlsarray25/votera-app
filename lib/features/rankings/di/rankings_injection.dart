import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/rankings/data/datasources/remote/leaderboard_remote_data_source.dart';
import 'package:votera/features/rankings/data/repositories/leaderboard_repository_impl.dart';
import 'package:votera/features/rankings/domain/repositories/leaderboard_repository.dart';
import 'package:votera/features/rankings/domain/usecases/get_final_results.dart';
import 'package:votera/features/rankings/domain/usecases/get_leaderboard.dart';
import 'package:votera/features/rankings/presentation/cubit/rankings_cubit.dart';

void initRankingsFeature(GetIt sl) {
  sl
    // Cubits — registered as factory so each screen gets a fresh instance.
    ..registerFactory<RankingsCubit>(
      () => RankingsCubit(
        getLeaderboard: sl<GetLeaderboard>(),
        getFinalResults: sl<GetFinalResults>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetLeaderboard>(
      () => GetLeaderboard(sl<LeaderboardRepository>()),
    )
    ..registerLazySingleton<GetFinalResults>(
      () => GetFinalResults(sl<LeaderboardRepository>()),
    )
    // Repositories
    ..registerLazySingleton<LeaderboardRepository>(
      () => LeaderboardRepositoryImpl(
        remote: sl<LeaderboardRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<LeaderboardRemoteDataSource>(
      () => LeaderboardRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

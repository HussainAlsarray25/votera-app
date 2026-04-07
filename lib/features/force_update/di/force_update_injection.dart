import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/force_update/data/datasources/remote/app_version_remote_data_source.dart';
import 'package:votera/features/force_update/data/repositories/app_version_repository_impl.dart';
import 'package:votera/features/force_update/domain/repositories/app_version_repository.dart';
import 'package:votera/features/force_update/domain/usecases/check_force_update.dart';
import 'package:votera/features/force_update/presentation/cubit/force_update_cubit.dart';

void initForceUpdateFeature(GetIt sl) {
  sl
    // Cubit — singleton so the check result persists across widget rebuilds.
    ..registerLazySingleton<ForceUpdateCubit>(
      () => ForceUpdateCubit(checkForceUpdate: sl<CheckForceUpdate>()),
    )
    // Use case
    ..registerLazySingleton<CheckForceUpdate>(
      () => CheckForceUpdate(repository: sl<AppVersionRepository>()),
    )
    // Repository
    ..registerLazySingleton<AppVersionRepository>(
      () => AppVersionRepositoryImpl(
        remoteDataSource: sl<AppVersionRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data source
    ..registerLazySingleton<AppVersionRemoteDataSource>(
      () => AppVersionRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

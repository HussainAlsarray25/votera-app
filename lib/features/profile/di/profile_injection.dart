import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:votera/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';
import 'package:votera/features/profile/domain/usecases/get_user_profile.dart';
import 'package:votera/features/profile/domain/usecases/update_user_profile.dart';
import 'package:votera/features/profile/presentation/cubit/profile_cubit.dart';

void initProfileFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getUserProfile: sl<GetUserProfile>(),
        updateUserProfile: sl<UpdateUserProfile>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetUserProfile>(
      () => GetUserProfile(sl<ProfileRepository>()),
    )
    ..registerLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(sl<ProfileRepository>()),
    )
    // Repositories
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remote: sl<ProfileRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

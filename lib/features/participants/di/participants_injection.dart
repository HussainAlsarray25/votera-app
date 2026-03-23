import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/participants/data/datasources/remote/participant_remote_data_source.dart';
import 'package:votera/features/participants/data/repositories/participant_repository_impl.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';
import 'package:votera/features/participants/domain/usecases/get_my_applications.dart';
import 'package:votera/features/participants/domain/usecases/get_my_participation.dart';
import 'package:votera/features/participants/domain/usecases/get_participants.dart';
import 'package:votera/features/participants/domain/usecases/register_for_event.dart';
import 'package:votera/features/participants/presentation/cubit/participants_cubit.dart';

/// Applications feature dependency registration.
/// Call this from [initFeatures] in injection_container.dart.
void initParticipantsFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<ApplicationsCubit>(
      () => ApplicationsCubit(
        getApplications: sl<GetApplications>(),
        submitApplication: sl<SubmitApplication>(),
        getMyApplication: sl<GetMyApplication>(),
        getMyApplications: sl<GetMyApplications>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetApplications>(
      () => GetApplications(sl<ApplicationRepository>()),
    )
    ..registerLazySingleton<SubmitApplication>(
      () => SubmitApplication(sl<ApplicationRepository>()),
    )
    ..registerLazySingleton<GetMyApplication>(
      () => GetMyApplication(sl<ApplicationRepository>()),
    )
    ..registerLazySingleton<GetMyApplications>(
      () => GetMyApplications(sl<ApplicationRepository>()),
    )
    // Repositories
    ..registerLazySingleton<ApplicationRepository>(
      () => ApplicationRepositoryImpl(
        remote: sl<ApplicationRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<ApplicationRemoteDataSource>(
      () => ApplicationRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

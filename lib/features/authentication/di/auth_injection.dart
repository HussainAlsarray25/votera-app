import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/authentication/data/datasources/remote/auth_remote_data_source.dart';
import 'package:votera/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:votera/features/authentication/data/services/token_service.dart';
import 'package:votera/features/authentication/domain/repositories/auth_repository.dart';
import 'package:votera/features/authentication/domain/usecases/login_user.dart';
import 'package:votera/features/authentication/domain/usecases/logout_user.dart';
import 'package:votera/features/authentication/domain/usecases/register_user.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';

void initAuthFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUser: sl<LoginUser>(),
        registerUser: sl<RegisterUser>(),
        logoutUser: sl<LogoutUser>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<LoginUser>(
      () => LoginUser(sl<AuthRepository>()),
    )
    ..registerLazySingleton<RegisterUser>(
      () => RegisterUser(sl<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUser>(
      () => LogoutUser(sl<AuthRepository>()),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
        tokenService: sl<TokenService>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

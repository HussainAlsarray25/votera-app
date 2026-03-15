import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/notification/data/datasources/remote/notification_remote_data_source.dart';
import 'package:votera/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';
import 'package:votera/features/notification/domain/usecases/get_notifications.dart';
import 'package:votera/features/notification/presentation/cubit/notification_cubit.dart';

void initNotificationFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<NotificationCubit>(
      () => NotificationCubit(
        getNotifications: sl<GetNotifications>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetNotifications>(
      () => GetNotifications(sl<NotificationRepository>()),
    )
    // Repositories
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: sl<NotificationRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/services/firebase_push_service.dart';
import 'package:votera/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:votera/features/notification/data/datasources/remote/notification_remote_data_source.dart';
import 'package:votera/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';
import 'package:votera/features/notification/domain/usecases/get_notifications.dart';
import 'package:votera/features/notification/domain/usecases/get_unread_count.dart';
import 'package:votera/features/notification/domain/usecases/mark_all_as_read.dart';
import 'package:votera/features/notification/domain/usecases/mark_as_read.dart';
import 'package:votera/features/notification/domain/usecases/register_device_token.dart';
import 'package:votera/features/notification/domain/usecases/remove_device_token.dart';
import 'package:votera/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/push_notification_cubit.dart';
import 'package:votera/features/notification/presentation/cubit/unread_count_cubit.dart';

void initNotificationFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<NotificationCubit>(
      () => NotificationCubit(
        getNotifications: sl<GetNotifications>(),
        markAsRead: sl<MarkAsRead>(),
        markAllAsRead: sl<MarkAllAsRead>(),
      ),
    )
    ..registerFactory<UnreadCountCubit>(
      () => UnreadCountCubit(
        getUnreadCount: sl<GetUnreadCount>(),
      ),
    )
    ..registerLazySingleton<PushNotificationCubit>(
      () => PushNotificationCubit(
        pushService: sl<FirebasePushService>(),
        authCubit: sl<AuthCubit>(),
        registerDeviceToken: sl<RegisterDeviceToken>(),
        removeDeviceToken: sl<RemoveDeviceToken>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetNotifications>(
      () => GetNotifications(sl<NotificationRepository>()),
    )
    ..registerLazySingleton<MarkAsRead>(
      () => MarkAsRead(sl<NotificationRepository>()),
    )
    ..registerLazySingleton<MarkAllAsRead>(
      () => MarkAllAsRead(sl<NotificationRepository>()),
    )
    ..registerLazySingleton<GetUnreadCount>(
      () => GetUnreadCount(sl<NotificationRepository>()),
    )
    ..registerLazySingleton<RegisterDeviceToken>(
      () => RegisterDeviceToken(sl<NotificationRepository>()),
    )
    ..registerLazySingleton<RemoveDeviceToken>(
      () => RemoveDeviceToken(sl<NotificationRepository>()),
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

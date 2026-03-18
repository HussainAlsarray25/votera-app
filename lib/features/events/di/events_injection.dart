import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/events/data/datasources/remote/event_remote_data_source.dart';
import 'package:votera/features/events/data/repositories/event_repository_impl.dart';
import 'package:votera/features/events/domain/repositories/event_repository.dart';
import 'package:votera/features/events/domain/usecases/get_event_by_id.dart';
import 'package:votera/features/events/domain/usecases/get_events.dart';
import 'package:votera/features/events/presentation/cubit/events_cubit.dart';

void initEventsFeature(GetIt sl) {
  sl
    // Cubits — registered as factory so each screen gets a fresh instance.
    ..registerFactory<EventsCubit>(
      () => EventsCubit(
        getEvents: sl<GetEvents>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<GetEvents>(
      () => GetEvents(sl<EventRepository>()),
    )
    ..registerLazySingleton<GetEventById>(
      () => GetEventById(sl<EventRepository>()),
    )
    // Repositories
    ..registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(
        remoteDataSource: sl<EventRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<EventRemoteDataSource>(
      () => EventRemoteDataSourceImpl(
        apiClient: sl<ApiClient>(),
      ),
    );
}

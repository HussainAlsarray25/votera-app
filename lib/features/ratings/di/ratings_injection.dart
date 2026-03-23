import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/ratings/data/datasources/remote/rating_remote_data_source.dart';
import 'package:votera/features/ratings/data/repositories/rating_repository_impl.dart';
import 'package:votera/features/ratings/domain/repositories/rating_repository.dart';
import 'package:votera/features/ratings/domain/usecases/get_my_rating.dart';
import 'package:votera/features/ratings/domain/usecases/get_rating_summary.dart';
import 'package:votera/features/ratings/domain/usecases/rate_project.dart';
import 'package:votera/features/ratings/presentation/cubit/ratings_cubit.dart';

/// Ratings feature dependency registration.
void initRatingsFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<RatingsCubit>(
      () => RatingsCubit(
        rateProject: sl<RateProject>(),
        getRatingSummary: sl<GetRatingSummary>(),
        getMyRating: sl<GetMyRating>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<RateProject>(
      () => RateProject(sl<RatingRepository>()),
    )
    ..registerLazySingleton<GetRatingSummary>(
      () => GetRatingSummary(sl<RatingRepository>()),
    )
    ..registerLazySingleton<GetMyRating>(
      () => GetMyRating(sl<RatingRepository>()),
    )
    // Repositories
    ..registerLazySingleton<RatingRepository>(
      () => RatingRepositoryImpl(
        remote: sl<RatingRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<RatingRemoteDataSource>(
      () => RatingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

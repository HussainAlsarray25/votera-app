import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/categories/data/datasources/remote/category_remote_data_source.dart';
import 'package:votera/features/categories/data/repositories/category_repository_impl.dart';
import 'package:votera/features/categories/domain/repositories/category_repository.dart';
import 'package:votera/features/categories/domain/usecases/get_categories.dart';
import 'package:votera/features/categories/domain/usecases/get_category_by_id.dart';
import 'package:votera/features/categories/presentation/cubit/categories_cubit.dart';

void initCategoriesFeature(GetIt sl) {
  sl
    // Cubits are registered as factories so each screen gets a fresh instance.
    ..registerFactory<CategoriesCubit>(
      () => CategoriesCubit(getCategories: sl<GetCategories>()),
    )

    // Use cases
    ..registerLazySingleton<GetCategories>(
      () => GetCategories(sl<CategoryRepository>()),
    )
    ..registerLazySingleton<GetCategoryById>(
      () => GetCategoryById(sl<CategoryRepository>()),
    )

    // Repositories
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        remoteDataSource: sl<CategoryRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )

    // Data sources
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

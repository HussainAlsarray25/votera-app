import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/categories/data/datasources/remote/category_remote_data_source.dart';
import 'package:votera/features/categories/data/models/category_model.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final CategoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedResponse<CategoryEntity>>> getCategories({
    required int page,
    required int size,
  }) async {
    // Guard against making a network call when there is no connection,
    // so the caller receives a typed failure rather than a socket exception.
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remoteDataSource.getCategories(page: page, size: size);
      final paginated = PaginatedResponse.fromJson(json, CategoryModel.fromJson);
      return Right(paginated);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remoteDataSource.getCategoryById(id);
      return Right(CategoryModel.fromJson(json));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';

/// Contract for all category data operations.
/// The implementation lives in the data layer and decides whether to
/// hit the network, a cache, or any other source.
abstract class CategoryRepository {
  /// Fetch a page of categories. Pagination is 1-based on the server side.
  Future<Either<Failure, PaginatedResponse<CategoryEntity>>> getCategories({
    required int page,
    required int size,
  });

  /// Fetch a single category by its unique identifier.
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);
}

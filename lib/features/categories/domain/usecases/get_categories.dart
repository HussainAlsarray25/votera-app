import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/domain/repositories/category_repository.dart';

/// Retrieves a paginated list of categories from the repository.
/// Callers control which page to load and how many items to request per page,
/// making this safe to reuse for both initial loads and infinite-scroll triggers.
class GetCategories
    extends UseCase<PaginatedResponse<CategoryEntity>, GetCategoriesParams> {
  GetCategories(this.repository);

  final CategoryRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<CategoryEntity>>> call(
    GetCategoriesParams params,
  ) {
    return repository.getCategories(page: params.page, size: params.size);
  }
}

/// Parameters for [GetCategories].
/// Bundled into a value object so the use-case signature stays stable
/// if extra filter criteria are added later.
class GetCategoriesParams extends Equatable {
  const GetCategoriesParams({required this.page, required this.size});

  final int page;
  final int size;

  @override
  List<Object> get props => [page, size];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/domain/repositories/category_repository.dart';

/// Fetches a single category by its unique identifier.
/// Kept as its own use-case so it can be composed independently of the list.
class GetCategoryById extends UseCase<CategoryEntity, GetCategoryByIdParams> {
  GetCategoryById(this.repository);

  final CategoryRepository repository;

  @override
  Future<Either<Failure, CategoryEntity>> call(GetCategoryByIdParams params) {
    return repository.getCategoryById(params.id);
  }
}

/// Parameters for [GetCategoryById].
class GetCategoryByIdParams extends Equatable {
  const GetCategoryByIdParams({required this.id});

  final String id;

  @override
  List<Object> get props => [id];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/categories/domain/entities/category_entity.dart';
import 'package:votera/features/categories/domain/usecases/get_categories.dart';

part 'categories_state.dart';

/// Manages the state for the categories listing screen.
/// Pagination parameters are passed by the caller so this cubit stays
/// reusable across any page size the UI decides to use.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({required this.getCategories})
      : super(const CategoriesInitial());

  final GetCategories getCategories;

  Future<void> loadCategories({required int page, required int size}) async {
    emit(const CategoriesLoading());
    final result = await getCategories(
      GetCategoriesParams(page: page, size: size),
    );
    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (response) => emit(CategoriesLoaded(response: response)),
    );
  }
}

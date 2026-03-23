part of 'categories_cubit.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// Emitted when the categories page has loaded successfully.
/// Carries the full paginated envelope so the UI can decide whether to show
/// a "load more" control based on [PaginatedResponse.hasNextPage].
class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded({required this.response});

  final PaginatedResponse<CategoryEntity> response;

  @override
  List<Object?> get props => [response];
}

class CategoriesError extends CategoriesState {
  const CategoriesError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

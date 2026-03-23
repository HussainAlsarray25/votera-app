import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class AddProjectCategoryParams extends Equatable {
  const AddProjectCategoryParams({
    required this.eventId,
    required this.projectId,
    required this.categoryId,
  });

  final String eventId;
  final String projectId;
  final String categoryId;

  @override
  List<Object> get props => [eventId, projectId, categoryId];
}

/// Tags a project with a category.
class AddProjectCategory extends UseCase<void, AddProjectCategoryParams> {
  AddProjectCategory(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(AddProjectCategoryParams params) {
    return repository.addProjectCategory(
      eventId: params.eventId,
      projectId: params.projectId,
      categoryId: params.categoryId,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class RemoveProjectCategoryParams extends Equatable {
  const RemoveProjectCategoryParams({
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

/// Removes a category tag from a project.
class RemoveProjectCategory extends UseCase<void, RemoveProjectCategoryParams> {
  RemoveProjectCategory(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveProjectCategoryParams params) {
    return repository.removeProjectCategory(
      eventId: params.eventId,
      projectId: params.projectId,
      categoryId: params.categoryId,
    );
  }
}

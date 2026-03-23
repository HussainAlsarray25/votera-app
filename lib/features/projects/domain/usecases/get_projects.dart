import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/projects/domain/entities/project_entity.dart';
import 'package:votera/features/projects/domain/repositories/project_repository.dart';

class GetProjects extends UseCase<PaginatedResponse<ProjectEntity>, GetProjectsParams> {
  GetProjects(this.repository);

  final ProjectRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<ProjectEntity>>> call(
    GetProjectsParams params,
  ) {
    return repository.getProjects(
      eventId: params.eventId,
      page: params.page,
      size: params.size,
    );
  }
}

class GetProjectsParams extends Equatable {
  const GetProjectsParams({
    required this.eventId,
    required this.page,
    required this.size,
  });

  final String eventId;
  final int page;
  final int size;

  @override
  List<Object?> get props => [eventId, page, size];
}

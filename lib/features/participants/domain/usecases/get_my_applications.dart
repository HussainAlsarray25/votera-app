import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';

class GetMyApplicationsParams extends Equatable {
  const GetMyApplicationsParams({
    required this.page,
    required this.size,
  });

  final int page;
  final int size;

  @override
  List<Object> get props => [page, size];
}

/// Returns the authenticated user's applications across all events.
class GetMyApplications
    extends UseCase<PaginatedResponse<ApplicationEntity>, GetMyApplicationsParams> {
  GetMyApplications(this.repository);

  final ApplicationRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> call(
    GetMyApplicationsParams params,
  ) {
    return repository.getMyApplications(
      page: params.page,
      size: params.size,
    );
  }
}

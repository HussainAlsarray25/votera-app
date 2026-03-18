import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';
import 'package:votera/features/participants/domain/repositories/participant_repository.dart';

/// Input parameters for [GetApplications].
class GetApplicationsParams extends Equatable {
  const GetApplicationsParams({
    required this.eventId,
    required this.page,
    required this.size,
  });

  final String eventId;
  final int page;
  final int size;

  @override
  List<Object> get props => [eventId, page, size];
}

/// Returns a paginated list of applications for a given event.
class GetApplications
    extends UseCase<PaginatedResponse<ApplicationEntity>, GetApplicationsParams> {
  GetApplications(this.repository);

  final ApplicationRepository repository;

  @override
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> call(
    GetApplicationsParams params,
  ) {
    return repository.getApplications(
      eventId: params.eventId,
      page: params.page,
      size: params.size,
    );
  }
}

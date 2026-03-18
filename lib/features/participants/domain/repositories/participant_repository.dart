import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/paginated_response.dart';
import 'package:votera/features/participants/domain/entities/participant_entity.dart';

/// Contract for all application data operations.
/// The implementation in the data layer decides whether to hit the network
/// or return a cached/offline result.
abstract class ApplicationRepository {
  /// Returns a paginated list of applications for [eventId].
  /// [page] is 1-based; [size] controls how many items per page.
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getApplications({
    required String eventId,
    required int page,
    required int size,
  });

  /// Submits an application on behalf of [teamId] for [eventId].
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required String eventId,
    required String teamId,
  });

  /// Returns the authenticated user's team application for [eventId].
  /// Requires [teamId] as a query parameter.
  Future<Either<Failure, ApplicationEntity>> getMyApplication({
    required String eventId,
    required String teamId,
  });
}

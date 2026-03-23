import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/ratings/domain/entities/rating_summary_entity.dart';
import 'package:votera/features/ratings/domain/repositories/rating_repository.dart';

class GetRatingSummaryParams extends Equatable {
  const GetRatingSummaryParams({required this.projectId});

  final String projectId;

  @override
  List<Object> get props => [projectId];
}

class GetRatingSummary
    extends UseCase<RatingSummaryEntity, GetRatingSummaryParams> {
  GetRatingSummary(this.repository);

  final RatingRepository repository;

  @override
  Future<Either<Failure, RatingSummaryEntity>> call(
    GetRatingSummaryParams params,
  ) {
    return repository.getRatingSummary(params.projectId);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/ratings/domain/entities/rating_entity.dart';
import 'package:votera/features/ratings/domain/repositories/rating_repository.dart';

class GetMyRatingParams extends Equatable {
  const GetMyRatingParams({required this.projectId});

  final String projectId;

  @override
  List<Object> get props => [projectId];
}

class GetMyRating extends UseCase<RatingEntity, GetMyRatingParams> {
  GetMyRating(this.repository);

  final RatingRepository repository;

  @override
  Future<Either<Failure, RatingEntity>> call(GetMyRatingParams params) {
    return repository.getMyRating(params.projectId);
  }
}

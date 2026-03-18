import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/ratings/domain/entities/rating_entity.dart';
import 'package:votera/features/ratings/domain/repositories/rating_repository.dart';

class RateProjectParams extends Equatable {
  const RateProjectParams({required this.projectId, required this.score});

  final String projectId;
  final int score;

  @override
  List<Object> get props => [projectId, score];
}

class RateProject extends UseCase<RatingEntity, RateProjectParams> {
  RateProject(this.repository);

  final RatingRepository repository;

  @override
  Future<Either<Failure, RatingEntity>> call(RateProjectParams params) {
    return repository.rateProject(
      projectId: params.projectId,
      score: params.score,
    );
  }
}

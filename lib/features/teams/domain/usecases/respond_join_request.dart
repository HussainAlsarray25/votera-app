import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class RespondJoinRequestParams extends Equatable {
  const RespondJoinRequestParams({
    required this.teamId,
    required this.requestId,
    required this.approve,
  });

  final String teamId;
  final String requestId;
  final bool approve;

  @override
  List<Object> get props => [teamId, requestId, approve];
}

class RespondJoinRequest extends UseCase<void, RespondJoinRequestParams> {
  RespondJoinRequest(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(RespondJoinRequestParams params) {
    return repository.respondJoinRequest(
      teamId: params.teamId,
      requestId: params.requestId,
      approve: params.approve,
    );
  }
}

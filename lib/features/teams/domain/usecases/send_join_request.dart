import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/entities/join_request_entity.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class SendJoinRequestParams extends Equatable {
  const SendJoinRequestParams({required this.teamId, this.message});

  final String teamId;
  final String? message;

  @override
  List<Object?> get props => [teamId, message];
}

class SendJoinRequest extends UseCase<JoinRequestEntity, SendJoinRequestParams> {
  SendJoinRequest(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, JoinRequestEntity>> call(SendJoinRequestParams params) {
    return repository.sendJoinRequest(
      teamId: params.teamId,
      message: params.message,
    );
  }
}

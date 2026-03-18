import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/teams/domain/repositories/team_repository.dart';

class TransferLeadershipParams extends Equatable {
  const TransferLeadershipParams({
    required this.teamId,
    required this.newLeaderId,
  });

  final String teamId;
  final String newLeaderId;

  @override
  List<Object> get props => [teamId, newLeaderId];
}

class TransferLeadership extends UseCase<void, TransferLeadershipParams> {
  TransferLeadership(this.repository);

  final TeamRepository repository;

  @override
  Future<Either<Failure, void>> call(TransferLeadershipParams params) {
    return repository.transferLeadership(
      teamId: params.teamId,
      newLeaderId: params.newLeaderId,
    );
  }
}

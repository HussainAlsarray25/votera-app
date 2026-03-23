import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class GetMyUidRequests extends UseCase<List<ParticipantRequest>, NoParams> {
  GetMyUidRequests(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, List<ParticipantRequest>>> call(NoParams params) {
    return repository.getMyUidRequests();
  }
}

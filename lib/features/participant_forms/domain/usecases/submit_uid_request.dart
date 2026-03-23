import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class SubmitUidRequest
    extends UseCase<ParticipantRequest, SubmitUidRequestParams> {
  SubmitUidRequest(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, ParticipantRequest>> call(
      SubmitUidRequestParams params) {
    return repository.submitUidRequest(
      fullName: params.fullName,
      universityId: params.universityId,
      department: params.department,
      stage: params.stage,
      documentUrl: params.documentUrl,
    );
  }
}

class SubmitUidRequestParams extends Equatable {
  const SubmitUidRequestParams({
    required this.fullName,
    required this.universityId,
    required this.department,
    required this.stage,
    required this.documentUrl,
  });

  final String fullName;
  final String universityId;
  final String department;
  final String stage;
  final String documentUrl;

  @override
  List<Object?> get props => [fullName, universityId, department, stage, documentUrl];
}

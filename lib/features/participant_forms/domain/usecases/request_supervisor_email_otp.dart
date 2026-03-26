import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class RequestSupervisorEmailOtp
    extends UseCase<void, RequestSupervisorEmailOtpParams> {
  RequestSupervisorEmailOtp(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, void>> call(RequestSupervisorEmailOtpParams params) {
    return repository.requestSupervisorEmailOtp(params.email);
  }
}

class RequestSupervisorEmailOtpParams extends Equatable {
  const RequestSupervisorEmailOtpParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class VerifySupervisorEmailOtp
    extends UseCase<void, VerifySupervisorEmailOtpParams> {
  VerifySupervisorEmailOtp(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifySupervisorEmailOtpParams params) {
    return repository.verifySupervisorEmailOtp(params.email, params.code);
  }
}

class VerifySupervisorEmailOtpParams extends Equatable {
  const VerifySupervisorEmailOtpParams({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

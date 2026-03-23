import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class VerifyEmailOtp extends UseCase<void, VerifyEmailOtpParams> {
  VerifyEmailOtp(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, void>> call(VerifyEmailOtpParams params) {
    return repository.verifyEmailOtp(params.email, params.code);
  }
}

class VerifyEmailOtpParams extends Equatable {
  const VerifyEmailOtpParams({required this.email, required this.code});

  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

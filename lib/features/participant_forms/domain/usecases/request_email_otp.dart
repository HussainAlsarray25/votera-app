import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class RequestEmailOtp extends UseCase<void, RequestEmailOtpParams> {
  RequestEmailOtp(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, void>> call(RequestEmailOtpParams params) {
    return repository.requestEmailOtp(params.email);
  }
}

class RequestEmailOtpParams extends Equatable {
  const RequestEmailOtpParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

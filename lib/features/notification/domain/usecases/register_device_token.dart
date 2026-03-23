import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class RegisterDeviceTokenParams extends Equatable {
  const RegisterDeviceTokenParams({
    required this.token,
    required this.platform,
  });

  final String token;
  final String platform;

  @override
  List<Object> get props => [token, platform];
}

class RegisterDeviceToken extends UseCase<void, RegisterDeviceTokenParams> {
  RegisterDeviceToken(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(RegisterDeviceTokenParams params) {
    return repository.registerDeviceToken(
      token: params.token,
      platform: params.platform,
    );
  }
}

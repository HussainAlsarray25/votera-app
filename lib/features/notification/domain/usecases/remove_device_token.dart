import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class RemoveDeviceTokenParams extends Equatable {
  const RemoveDeviceTokenParams({required this.token});

  final String token;

  @override
  List<Object> get props => [token];
}

class RemoveDeviceToken extends UseCase<void, RemoveDeviceTokenParams> {
  RemoveDeviceToken(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveDeviceTokenParams params) {
    return repository.removeDeviceToken(params.token);
  }
}

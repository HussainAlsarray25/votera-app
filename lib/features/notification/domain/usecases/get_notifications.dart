import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class GetNotifications
    extends UseCase<List<NotificationEntity>, NoParams> {
  GetNotifications(this.repository);

  final NotificationRepository repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) {
    return repository.getNotifications();
  }
}

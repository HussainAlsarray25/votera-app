import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/notification/data/datasources/remote/notification_remote_data_source.dart';
import 'package:votera/features/notification/data/models/notification_model.dart';
import 'package:votera/features/notification/domain/entities/notification_entity.dart';
import 'package:votera/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remoteDataSource.getNotifications();
      final notifications = result.map(NotificationModel.fromJson).toList();
      return Right(notifications);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

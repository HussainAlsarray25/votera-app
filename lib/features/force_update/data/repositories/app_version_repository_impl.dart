import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/force_update/data/datasources/remote/app_version_remote_data_source.dart';
import 'package:votera/features/force_update/data/models/app_version_model.dart';
import 'package:votera/features/force_update/domain/entities/app_version_entity.dart';
import 'package:votera/features/force_update/domain/repositories/app_version_repository.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  const AppVersionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final AppVersionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, AppVersionEntity>> getLatestVersion() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final json = await remoteDataSource.getLatestVersion();
      return Right(AppVersionModel.fromJson(json));
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }
}

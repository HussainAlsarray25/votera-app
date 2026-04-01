import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/force_update/domain/entities/app_version_entity.dart';

abstract class AppVersionRepository {
  Future<Either<Failure, AppVersionEntity>> getLatestVersion();
}

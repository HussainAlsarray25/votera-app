import 'package:dartz/dartz.dart';
import 'package:votera/core/error/error_message_extractor.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/profile/data/datasources/local/profile_local_data_source.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:votera/features/profile/data/models/user_profile_model.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  final ProfileRemoteDataSource remote;
  final ProfileLocalDataSource local;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getUserProfile();
      final profile = UserProfileModel.fromJson(result);
      // Cache the fresh profile so subsequent launches are instant.
      await local.cacheProfile(profile);
      return Right(profile);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    String? fullName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.updateUserProfile(fullName: fullName);
      final profile = UserProfileModel.fromJson(result);
      await local.cacheProfile(profile);
      return Right(profile);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final url = await remote.uploadAvatar(
        filePath: filePath,
        bytes: bytes,
        fileName: fileName,
      );
      return Right(url);
    } on Exception catch (e) {
      return Left(ServerFailure(message: extractErrorMessage(e)));
    }
  }

  @override
  Future<UserProfile?> getCachedProfile() => local.getCachedProfile();

  @override
  Future<void> clearCache() => local.clearCache();
}

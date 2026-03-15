import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:votera/features/profile/data/models/user_profile_model.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remote,
    required this.networkInfo,
  });

  final ProfileRemoteDataSource remote;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final result = await remote.getUserProfile();
      return Right(UserProfileModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }
    try {
      final result = await remote.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
      );
      return Right(UserProfileModel.fromJson(result));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

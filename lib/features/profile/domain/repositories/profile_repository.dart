import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile();
  Future<Either<Failure, UserProfile>> updateUserProfile({
    String? fullName,
  });
  /// [filePath] is used on mobile/desktop. [bytes] + [fileName] are used on web
  /// where a file path is not available.
  Future<Either<Failure, String>> uploadAvatar({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  });
  Future<UserProfile?> getCachedProfile();
  Future<void> clearCache();
}

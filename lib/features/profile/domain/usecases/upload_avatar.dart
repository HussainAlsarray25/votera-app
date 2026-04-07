import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/profile/domain/repositories/profile_repository.dart';

class UploadAvatar extends UseCase<String, UploadAvatarParams> {
  UploadAvatar(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return repository.uploadAvatar(
      filePath: params.filePath,
      bytes: params.bytes,
      fileName: params.fileName,
    );
  }
}

class UploadAvatarParams extends Equatable {
  const UploadAvatarParams({
    this.filePath,
    this.bytes,
    this.fileName,
  });

  /// File path — available on mobile and desktop.
  final String? filePath;

  /// Raw file bytes — used on web where a path is not available.
  final List<int>? bytes;

  /// Original file name — required when uploading via bytes (web).
  final String? fileName;

  @override
  List<Object?> get props => [filePath, bytes, fileName];
}

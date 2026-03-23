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
    return repository.uploadAvatar(params.filePath);
  }
}

class UploadAvatarParams extends Equatable {
  const UploadAvatarParams({required this.filePath});

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

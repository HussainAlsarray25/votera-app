import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';

class UploadUidDocument extends UseCase<String, UploadUidDocumentParams> {
  UploadUidDocument(this.repository);

  final FormsRepository repository;

  @override
  Future<Either<Failure, String>> call(UploadUidDocumentParams params) {
    return repository.uploadUidDocument(
      fileName: params.fileName,
      bytes: params.bytes,
    );
  }
}

class UploadUidDocumentParams extends Equatable {
  const UploadUidDocumentParams({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final List<int> bytes;

  @override
  List<Object?> get props => [fileName];
}

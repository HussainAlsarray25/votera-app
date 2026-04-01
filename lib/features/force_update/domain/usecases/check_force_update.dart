import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/force_update/domain/repositories/app_version_repository.dart';

/// The result returned by [CheckForceUpdate].
///
/// Carries whether an update is mandatory, the download URL,
/// and server-provided localized messages for the dialog.
class ForceUpdateResult extends Equatable {
  const ForceUpdateResult({
    required this.isUpdateRequired,
    required this.updateUrl,
    required this.latestVersionName,
    required this.messageEn,
    required this.messageAr,
  });

  final bool isUpdateRequired;
  final String updateUrl;

  /// Human-readable version name to show in the dialog (e.g. "2.1.0").
  final String latestVersionName;

  /// Server-provided update message in English.
  final String messageEn;

  /// Server-provided update message in Arabic.
  final String messageAr;

  @override
  List<Object?> get props => [
        isUpdateRequired,
        updateUrl,
        latestVersionName,
        messageEn,
        messageAr,
      ];
}

/// Fetches the latest version info from the server and reads the
/// [AppVersionEntity.forceUpdate] flag to decide if an update is required.
///
/// The server is the source of truth — no local version comparison is needed.
class CheckForceUpdate extends UseCase<ForceUpdateResult, NoParams> {
  CheckForceUpdate({required this.repository});

  final AppVersionRepository repository;

  @override
  Future<Either<Failure, ForceUpdateResult>> call(NoParams params) async {
    final result = await repository.getLatestVersion();
    return result.map(
      (versionInfo) => ForceUpdateResult(
        isUpdateRequired: versionInfo.forceUpdate,
        updateUrl: versionInfo.updateUrl,
        latestVersionName: versionInfo.latestVersionName,
        messageEn: versionInfo.messageEn,
        messageAr: versionInfo.messageAr,
      ),
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/force_update/domain/usecases/check_force_update.dart';

part 'force_update_state.dart';

/// Runs the version check once at app startup and exposes the result
/// so [ForceUpdateGuard] can decide whether to block the UI.
class ForceUpdateCubit extends Cubit<ForceUpdateState> {
  ForceUpdateCubit({required this.checkForceUpdate})
      : super(ForceUpdateInitial());

  final CheckForceUpdate checkForceUpdate;

  Future<void> check() async {
    emit(ForceUpdateChecking());
    final result = await checkForceUpdate(NoParams());
    result.fold(
      (failure) => emit(ForceUpdateCheckFailed(message: failure.message)),
      (updateResult) {
        if (updateResult.isUpdateRequired) {
          emit(ForceUpdateRequired(
            updateUrl: updateResult.updateUrl,
            latestVersionName: updateResult.latestVersionName,
            messageEn: updateResult.messageEn,
            messageAr: updateResult.messageAr,
          ));
        } else {
          emit(ForceUpdateNotRequired());
        }
      },
    );
  }
}

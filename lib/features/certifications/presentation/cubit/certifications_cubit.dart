import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';
import 'package:votera/features/certifications/domain/usecases/get_my_certification.dart';
import 'package:votera/features/certifications/domain/usecases/submit_certification.dart';

part 'certifications_state.dart';

/// Manages certification request state transitions.
class CertificationsCubit extends Cubit<CertificationsState> {
  CertificationsCubit({
    required this.submitCertification,
    required this.getMyCertification,
  }) : super(const CertificationsInitial());

  final SubmitCertification submitCertification;
  final GetMyCertification getMyCertification;

  Future<void> submit({
    required CertificationType type,
    required String documentUrl,
  }) async {
    emit(const CertificationsLoading());
    final result = await submitCertification(
      SubmitCertificationParams(type: type, documentUrl: documentUrl),
    );
    result.fold(
      (failure) => emit(CertificationsError(message: failure.message)),
      (cert) => emit(CertificationLoaded(certification: cert)),
    );
  }

  Future<void> loadMyCertification(CertificationType type) async {
    emit(const CertificationsLoading());
    final result = await getMyCertification(
      GetMyCertificationParams(type: type),
    );
    result.fold(
      (failure) => emit(CertificationsError(message: failure.message)),
      (cert) => emit(CertificationLoaded(certification: cert)),
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera/core/usecases/usecase.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';
import 'package:votera/features/participant_forms/domain/usecases/get_my_uid_requests.dart';
import 'package:votera/features/participant_forms/domain/usecases/request_email_otp.dart';
import 'package:votera/features/participant_forms/domain/usecases/request_supervisor_email_otp.dart';
import 'package:votera/features/participant_forms/domain/usecases/submit_uid_request.dart';
import 'package:votera/features/participant_forms/domain/usecases/verify_email_otp.dart';
import 'package:votera/features/participant_forms/domain/usecases/verify_supervisor_email_otp.dart';

part 'forms_state.dart';

/// Manages the participant-forms verification flows:
///   - Student email OTP: requestEmailOtp → verifyEmailOtp
///   - Supervisor email OTP: requestSupervisorEmailOtp → verifySupervisorEmailOtp
///   - UID card: loadMyUidRequests → submitUidRequest (with document in single step)
class FormsCubit extends Cubit<FormsState> {
  FormsCubit({
    required this.requestEmailOtp,
    required this.verifyEmailOtp,
    required this.requestSupervisorEmailOtp,
    required this.verifySupervisorEmailOtp,
    required this.getMyUidRequests,
    required this.submitUidRequest,
  }) : super(FormsInitial());

  final RequestEmailOtp requestEmailOtp;
  final VerifyEmailOtp verifyEmailOtp;
  final RequestSupervisorEmailOtp requestSupervisorEmailOtp;
  final VerifySupervisorEmailOtp verifySupervisorEmailOtp;
  final GetMyUidRequests getMyUidRequests;
  final SubmitUidRequest submitUidRequest;

  Future<void> sendEmailOtp(String email) async {
    emit(FormsLoading());
    final result = await requestEmailOtp(RequestEmailOtpParams(email: email));
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (_) => emit(FormsEmailOtpSent(email: email)),
    );
  }

  Future<void> confirmEmailOtp(String email, String code) async {
    emit(FormsLoading());
    final result = await verifyEmailOtp(
      VerifyEmailOtpParams(email: email, code: code),
    );
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (_) => emit(FormsEmailVerified()),
    );
  }

  Future<void> sendSupervisorEmailOtp(String email) async {
    emit(FormsLoading());
    final result = await requestSupervisorEmailOtp(
      RequestSupervisorEmailOtpParams(email: email),
    );
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (_) => emit(FormsSupEmailOtpSent(email: email)),
    );
  }

  Future<void> confirmSupervisorEmailOtp(String email, String code) async {
    emit(FormsLoading());
    final result = await verifySupervisorEmailOtp(
      VerifySupervisorEmailOtpParams(email: email, code: code),
    );
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (_) => emit(FormsSupervisorEmailVerified()),
    );
  }

  Future<void> loadMyUidRequests() async {
    emit(FormsLoading());
    final result = await getMyUidRequests(NoParams());
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (requests) => emit(FormsUidRequestsLoaded(requests: requests)),
    );
  }

  /// Submits a UID card request with document in a single step.
  /// The document is uploaded as multipart form data along with the form fields.
  Future<void> submitUid({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required List<int> documentBytes,
    required String documentFileName,
  }) async {
    emit(FormsLoading());
    final result = await submitUidRequest(
      SubmitUidRequestParams(
        fullName: fullName,
        universityId: universityId,
        department: department,
        stage: stage,
        documentBytes: documentBytes,
        documentFileName: documentFileName,
      ),
    );
    result.fold(
      (failure) => emit(FormsError(message: failure.message)),
      (_) => emit(FormsUidSubmitted()),
    );
  }
}

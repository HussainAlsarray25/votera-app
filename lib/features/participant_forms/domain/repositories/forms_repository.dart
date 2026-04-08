import 'package:dartz/dartz.dart';
import 'package:votera/core/error/failures.dart';
import 'package:votera/features/participant_forms/domain/entities/participant_request.dart';

abstract class FormsRepository {
  /// Sends a 6-digit OTP to the provided institutional email.
  Future<Either<Failure, void>> requestEmailOtp(String email);

  /// Verifies the OTP; on success the participant role is granted by the backend.
  Future<Either<Failure, void>> verifyEmailOtp(String email, String code);

  /// Returns all UID card requests submitted by the current user.
  Future<Either<Failure, List<ParticipantRequest>>> getMyUidRequests();

  /// Submits a new UID card participant request with document for admin review.
  /// The document is uploaded as multipart form data along with the form fields.
  Future<Either<Failure, ParticipantRequest>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required List<int> documentBytes,
    required String documentFileName,
  });

  /// Sends a 6-digit OTP to the provided supervisor email.
  Future<Either<Failure, void>> requestSupervisorEmailOtp(String email);

  /// Verifies the OTP; on success the supervisor role is granted by the backend.
  Future<Either<Failure, void>> verifySupervisorEmailOtp(String email, String code);
}

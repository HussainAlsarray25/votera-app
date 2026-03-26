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

  /// Uploads a document to MinIO via a presigned URL and returns the public URL.
  Future<Either<Failure, String>> uploadUidDocument({
    required String fileName,
    required List<int> bytes,
  });

  /// Submits a new UID card participant request for admin review.
  Future<Either<Failure, ParticipantRequest>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required String documentUrl,
  });

  /// Sends a 6-digit OTP to the provided supervisor email.
  Future<Either<Failure, void>> requestSupervisorEmailOtp(String email);

  /// Verifies the OTP; on success the supervisor role is granted by the backend.
  Future<Either<Failure, void>> verifySupervisorEmailOtp(String email, String code);
}

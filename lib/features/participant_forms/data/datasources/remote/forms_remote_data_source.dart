import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/participant_forms/data/datasources/remote/forms_endpoints.dart';

abstract class FormsRemoteDataSource {
  /// POST /forms/participants/email — sends OTP to the provided institutional email.
  Future<void> requestEmailOtp(String institutionalEmail);

  /// POST /forms/participants/email/verify — verifies OTP and grants participant role.
  Future<void> verifyEmailOtp(String institutionalEmail, String code);

  /// GET /forms/participants/uid — returns all UID requests submitted by the current user.
  Future<List<Map<String, dynamic>>> getMyUidRequests();

  /// Uploads a document to MinIO via a presigned URL and returns the public URL.
  /// Step 1: POST /forms/participants/uid/upload-url to get presigned PUT URL.
  /// Step 2: PUT file bytes directly to MinIO (no auth headers).
  Future<String> uploadUidDocument({
    required String fileName,
    required List<int> bytes,
  });

  /// POST /forms/participants/uid — submits a UID card request for admin review.
  Future<Map<String, dynamic>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required String documentUrl,
  });

  /// POST /forms/supervisors/email — sends OTP to the provided supervisor email.
  Future<void> requestSupervisorEmailOtp(String supervisorEmail);

  /// POST /forms/supervisors/email/verify — verifies OTP and grants supervisor role.
  Future<void> verifySupervisorEmailOtp(String supervisorEmail, String code);
}

class FormsRemoteDataSourceImpl implements FormsRemoteDataSource {
  FormsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // A bare Dio instance without auth interceptors, used only for uploading to
  // the presigned MinIO URL which does not require authentication headers.
  final Dio _uploadDio = Dio();

  @override
  Future<void> requestEmailOtp(String institutionalEmail) async {
    await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.requestEmailOtp,
      data: {'institutional_email': institutionalEmail},
    );
  }

  @override
  Future<void> verifyEmailOtp(String institutionalEmail, String code) async {
    await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.verifyEmailOtp,
      data: {'institutional_email': institutionalEmail, 'code': code},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMyUidRequests() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      FormsEndpoints.uidRequests,
    );
    final data = response.data?['data'];
    if (data == null) return [];
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<String> uploadUidDocument({
    required String fileName,
    required List<int> bytes,
  }) async {
    // Step 1: request a 15-minute presigned PUT URL from our backend.
    final urlResponse = await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.uidUploadUrl,
      data: {'file_name': fileName},
    );
    final data = urlResponse.data!['data'] as Map<String, dynamic>;
    final uploadUrl = data['upload_url'] as String;
    final publicUrl = data['public_url'] as String;

    // Step 2: PUT the file bytes directly to MinIO using the presigned URL.
    // The presigned URL already embeds auth — no extra headers are needed.
    await _uploadDio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {'Content-Length': bytes.length},
        contentType: 'application/octet-stream',
      ),
    );

    return publicUrl;
  }

  @override
  Future<Map<String, dynamic>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required String documentUrl,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.uidRequests,
      data: {
        'full_name': fullName,
        'university_id': universityId,
        'department': department,
        'stage': stage,
        'document_url': documentUrl,
      },
    );
    return response.data!;
  }

  @override
  Future<void> requestSupervisorEmailOtp(String supervisorEmail) async {
    await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.requestSupervisorEmailOtp,
      data: {'supervisor_email': supervisorEmail},
    );
  }

  @override
  Future<void> verifySupervisorEmailOtp(String supervisorEmail, String code) async {
    await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.verifySupervisorEmailOtp,
      data: {'supervisor_email': supervisorEmail, 'code': code},
    );
  }
}

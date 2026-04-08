import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/participant_forms/data/datasources/remote/forms_endpoints.dart';

abstract class FormsRemoteDataSource {
  Future<void> requestEmailOtp(String institutionalEmail);
  Future<void> verifyEmailOtp(String institutionalEmail, String code);
  Future<List<Map<String, dynamic>>> getMyUidRequests();
  Future<Map<String, dynamic>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required List<int> documentBytes,
    required String documentFileName,
  });
  Future<void> requestSupervisorEmailOtp(String supervisorEmail);
  Future<void> verifySupervisorEmailOtp(String supervisorEmail, String code);
}

class FormsRemoteDataSourceImpl implements FormsRemoteDataSource {
  FormsRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

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
  Future<Map<String, dynamic>> submitUidRequest({
    required String fullName,
    required String universityId,
    required String department,
    required String stage,
    required List<int> documentBytes,
    required String documentFileName,
  }) async {
    final formData = FormData.fromMap({
      'full_name': fullName,
      'university_id': universityId,
      'department': department,
      'stage': stage,
      'document': MultipartFile.fromBytes(
        documentBytes,
        filename: documentFileName,
      ),
    });

    final response = await apiClient.post<Map<String, dynamic>>(
      FormsEndpoints.uidRequests,
      data: formData,
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

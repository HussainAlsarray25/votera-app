import 'package:votera/core/network/api_client.dart';
import 'package:votera/features/certifications/data/datasources/remote/certification_endpoints.dart';
import 'package:votera/features/certifications/data/models/certification_model.dart';
import 'package:votera/features/certifications/domain/entities/certification_entity.dart';

abstract class CertificationRemoteDataSource {
  /// POST /v1/certifications
  Future<CertificationModel> submitCertification({
    required CertificationType type,
    required String documentUrl,
  });

  /// GET /v1/certifications/my?type={type}
  Future<CertificationModel> getMyCertification(CertificationType type);
}

class CertificationRemoteDataSourceImpl
    implements CertificationRemoteDataSource {
  const CertificationRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<CertificationModel> submitCertification({
    required CertificationType type,
    required String documentUrl,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      CertificationEndpoints.certifications,
      data: {
        'type': type.name,
        'document_url': documentUrl,
      },
    );
    return CertificationModel.fromJson(response.data!);
  }

  @override
  Future<CertificationModel> getMyCertification(
    CertificationType type,
  ) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      CertificationEndpoints.myCertification,
      queryParameters: {'type': type.name},
    );
    return CertificationModel.fromJson(response.data!);
  }
}

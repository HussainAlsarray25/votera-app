import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/certifications/data/datasources/remote/certification_remote_data_source.dart';
import 'package:votera/features/certifications/data/repositories/certification_repository_impl.dart';
import 'package:votera/features/certifications/domain/repositories/certification_repository.dart';
import 'package:votera/features/certifications/domain/usecases/get_certification_upload_url.dart';
import 'package:votera/features/certifications/domain/usecases/get_my_certification.dart';
import 'package:votera/features/certifications/domain/usecases/submit_certification.dart';
import 'package:votera/features/certifications/presentation/cubit/certifications_cubit.dart';

/// Certifications feature dependency registration.
void initCertificationsFeature(GetIt sl) {
  sl
    // Cubits
    ..registerFactory<CertificationsCubit>(
      () => CertificationsCubit(
        submitCertification: sl<SubmitCertification>(),
        getMyCertification: sl<GetMyCertification>(),
        getCertificationUploadUrl: sl<GetCertificationUploadUrl>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<SubmitCertification>(
      () => SubmitCertification(sl<CertificationRepository>()),
    )
    ..registerLazySingleton<GetMyCertification>(
      () => GetMyCertification(sl<CertificationRepository>()),
    )
    ..registerLazySingleton<GetCertificationUploadUrl>(
      () => GetCertificationUploadUrl(sl<CertificationRepository>()),
    )
    // Repositories
    ..registerLazySingleton<CertificationRepository>(
      () => CertificationRepositoryImpl(
        remote: sl<CertificationRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data sources
    ..registerLazySingleton<CertificationRemoteDataSource>(
      () => CertificationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

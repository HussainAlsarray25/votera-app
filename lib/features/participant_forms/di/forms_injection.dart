import 'package:get_it/get_it.dart';
import 'package:votera/core/network/api_client.dart';
import 'package:votera/core/network/network_info.dart';
import 'package:votera/features/participant_forms/data/datasources/remote/forms_remote_data_source.dart';
import 'package:votera/features/participant_forms/data/repositories/forms_repository_impl.dart';
import 'package:votera/features/participant_forms/domain/repositories/forms_repository.dart';
import 'package:votera/features/participant_forms/domain/usecases/get_my_uid_requests.dart';
import 'package:votera/features/participant_forms/domain/usecases/request_email_otp.dart';
import 'package:votera/features/participant_forms/domain/usecases/submit_uid_request.dart';
import 'package:votera/features/participant_forms/domain/usecases/upload_uid_document.dart';
import 'package:votera/features/participant_forms/domain/usecases/verify_email_otp.dart';
import 'package:votera/features/participant_forms/presentation/cubit/forms_cubit.dart';

void initFormsFeature(GetIt sl) {
  sl
    // Cubit — factory so each page gets a fresh instance.
    ..registerFactory<FormsCubit>(
      () => FormsCubit(
        requestEmailOtp: sl<RequestEmailOtp>(),
        verifyEmailOtp: sl<VerifyEmailOtp>(),
        getMyUidRequests: sl<GetMyUidRequests>(),
        uploadUidDocument: sl<UploadUidDocument>(),
        submitUidRequest: sl<SubmitUidRequest>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<RequestEmailOtp>(
      () => RequestEmailOtp(sl<FormsRepository>()),
    )
    ..registerLazySingleton<VerifyEmailOtp>(
      () => VerifyEmailOtp(sl<FormsRepository>()),
    )
    ..registerLazySingleton<GetMyUidRequests>(
      () => GetMyUidRequests(sl<FormsRepository>()),
    )
    ..registerLazySingleton<UploadUidDocument>(
      () => UploadUidDocument(sl<FormsRepository>()),
    )
    ..registerLazySingleton<SubmitUidRequest>(
      () => SubmitUidRequest(sl<FormsRepository>()),
    )
    // Repository
    ..registerLazySingleton<FormsRepository>(
      () => FormsRepositoryImpl(
        remoteDataSource: sl<FormsRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    )
    // Data source
    ..registerLazySingleton<FormsRemoteDataSource>(
      () => FormsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
}

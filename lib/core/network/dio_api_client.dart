import 'package:dio/dio.dart';
import 'package:votera/core/network/api_client.dart';

class DioApiClient implements ApiClient {
  const DioApiClient({required this.dio});

  final Dio dio;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestData = _processFormData(data, options);
      return await dio.post<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestData = _processFormData(data, options);
      return await dio.put<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestData = _processFormData(data, options);
      return await dio.patch<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final requestData = _processFormData(data, options);
      return await dio.delete<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Object? _processFormData(Object? data, Options? options) {
    if (data is Map<String, dynamic> &&
        options?.contentType == 'multipart/form-data') {
      return FormData.fromMap(data);
    }
    return data;
  }

  Exception _handleDioException(DioException e) {
    return e;
  }
}

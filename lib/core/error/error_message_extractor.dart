import 'package:dio/dio.dart';

/// Extracts a user-friendly error message from an exception.
///
/// For [DioException] with a JSON response body that follows the API
/// envelope `{"error": {"message": "..."}}`, it returns the server's
/// message. For all other exceptions it falls back to a generic message.
String extractErrorMessage(Exception e) {
  if (e is DioException) {
    // Try to read the structured error from the response body.
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) return message;
      }
      // Some endpoints return a flat "message" field.
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }

    // Fallback to HTTP status description.
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      return 'Server error ($statusCode)';
    }

    // Connection-level failures.
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out';
    }

    return 'Could not reach the server';
  }

  return e.toString();
}

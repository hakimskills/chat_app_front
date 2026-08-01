import 'package:dio/dio.dart';

/// Wraps a Dio error into a clean, displayable message. Laravel validation
/// errors come back as { "message": "...", "errors": { "field": ["msg"] } }
/// — this pulls out the first useful message so the UI doesn't need to
/// know about Laravel's error shape at all.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromDioError(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
        final firstField = (data['errors'] as Map).values.first;
        if (firstField is List && firstField.isNotEmpty) {
          return ApiException(firstField.first.toString());
        }
      }
      if (data['message'] is String) {
        return ApiException(data['message'] as String);
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiException('Could not reach the server. Check your connection.');
    }

    return ApiException('Something went wrong. Please try again.');
  }

  @override
  String toString() => message;
}

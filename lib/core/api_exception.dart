import 'dart:convert';

import 'package:http/http.dart' as http;

/// Wraps an HTTP response/error into a clean, displayable message.
/// Laravel validation errors come back as
/// { "message": "...", "errors": { "field": ["msg"] } } — this pulls out
/// the first useful message so the UI never has to know Laravel's shape.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
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
    } catch (_) {
      // Response body wasn't JSON (e.g. an HTML error page) — fall through.
    }
    return ApiException('Something went wrong (HTTP ${response.statusCode}).');
  }

  factory ApiException.network() => ApiException(
      'Could not reach the server. Check the IP address, WiFi, and firewall.');

  @override
  String toString() => message;
}

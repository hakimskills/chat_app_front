import 'dart:convert';

import 'package:http/http.dart' as http;

import 'constants.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.instance.getToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return http.get(uri, headers: await _headers()).timeout(_timeout);
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return http
        .put(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }

  Future<http.Response> delete(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return http
        .delete(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(_timeout);
  }
}

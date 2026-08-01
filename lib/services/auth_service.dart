import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/constants.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final String accessToken;
  AuthResult({required this.user, required this.accessToken});
}

class AuthService {
  final ApiClient _client = ApiClient.instance;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String deviceName = 'Flutter App',
  }) async {
    final response = await _safePost(ApiConstants.register, {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': deviceName,
    });
    return _handleAuthResponse(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    String deviceName = 'Flutter App',
  }) async {
    final response = await _safePost(ApiConstants.login, {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });
    return _handleAuthResponse(response);
  }

  Future<AuthResult> loginWithGoogle({
    required String idToken,
    String deviceName = 'Flutter App',
  }) async {
    final response = await _safePost(ApiConstants.google, {
      'id_token': idToken,
      'device_name': deviceName,
    });
    return _handleAuthResponse(response);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _safeGet(ApiConstants.me);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data['user']);
    }
    throw ApiException.fromResponse(response);
  }

  Future<void> logout() async {
    try {
      final response = await _safePost(ApiConstants.logout, {});
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException.fromResponse(response);
      }
    } finally {
      // Always clear the local token, even if the server call failed —
      // e.g. token was already invalid/revoked elsewhere.
      await TokenStorage.instance.deleteToken();
    }
  }

  Future<AuthResult> _handleAuthResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user']);
      final token = data['access_token'] as String;
      await TokenStorage.instance.saveToken(token);
      return AuthResult(user: user, accessToken: token);
    }
    throw ApiException.fromResponse(response);
  }

  Future<http.Response> _safePost(
      String path, Map<String, dynamic> body) async {
    try {
      return await _client.post(path, body);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }

  Future<http.Response> _safeGet(String path) async {
    try {
      return await _client.get(path);
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }
  }
}

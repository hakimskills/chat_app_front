import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/constants.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';

/// Result of any auth call — user + the token that was just issued.
class AuthResult {
  final UserModel user;
  final String accessToken;
  AuthResult({required this.user, required this.accessToken});
}

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String deviceName = 'Flutter App',
  }) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': deviceName,
      });
      return _handleAuthResponse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
    String deviceName = 'Flutter App',
  }) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      });
      return _handleAuthResponse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<AuthResult> loginWithGoogle({
    required String idToken,
    String deviceName = 'Flutter App',
  }) async {
    try {
      final response = await _dio.post(ApiConstants.google, data: {
        'id_token': idToken,
        'device_name': deviceName,
      });
      return _handleAuthResponse(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Even if the server call fails (e.g. token already invalid),
      // we still want to clear local state — see AuthProvider.logout().
      throw ApiException.fromDioError(e);
    } finally {
      await TokenStorage.instance.deleteToken();
    }
  }

  Future<AuthResult> _handleAuthResponse(Map<String, dynamic> data) async {
    final user = UserModel.fromJson(data['user']);
    final token = data['access_token'] as String;
    await TokenStorage.instance.saveToken(token);
    return AuthResult(user: user, accessToken: token);
  }
}

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/api_exception.dart';
import '../core/constants.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConstants.googleServerClientId,
    scopes: ['email'],
  );

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  /// Call this once on app start (see SplashScreen) to check whether a
  /// stored token is still valid, and restore the session if so.
  Future<void> checkAuthStatus() async {
    final token = await TokenStorage.instance.getToken();

    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      user = await _authService.getCurrentUser();
      status = AuthStatus.authenticated;
    } catch (_) {
      // Token exists but is no longer valid (expired/revoked elsewhere).
      await TokenStorage.instance.deleteToken();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _runAuthAction(() => _authService.register(
          name: name,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ));
  }

  Future<bool> login({required String email, required String password}) {
    return _runAuthAction(
        () => _authService.login(email: email, password: password));
  }

  Future<bool> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        // User cancelled the Google sign-in sheet.
        isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleAccount.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw ApiException('Google did not return an ID token.');
      }

      final result = await _authService.loginWithGoogle(idToken: idToken);
      user = result.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('🔴 Google sign-in error: $e');
      errorMessage =
          e is ApiException ? e.message : 'Google sign-in failed: $e';

      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (_) {
      // Ignore — local state is cleared regardless (see AuthService.logout).
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    user = null;
    status = AuthStatus.unauthenticated;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<AuthResult> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await action();
      user = result.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is ApiException ? e.message : 'Something went wrong.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

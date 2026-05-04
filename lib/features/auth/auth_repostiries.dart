// ============================================================
// features/auth/services/auth_service.dart
//
// Pure network layer — makes Dio calls, parses responses,
// saves tokens, throws AppException on failure.
//
// NO Flutter/UI code here.
// NO business logic here (that's the provider's job).
// NO hardcoded endpoints (everything from AuthEndpoints).
// ============================================================

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/token_storage.dart';
import '../../core/api_endpoints.dart';
import 'auth_models.dart';

class AuthService {
  final DioClient _client;
  final TokenStorage _storage;

  const AuthService({
    required DioClient client,
    required TokenStorage storage,
  }) : _client = client, _storage = storage;

  // ── Sign Up ────────────────────────────────────────────────

  Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.signUp,
        data: request.toJson(),
      );
      final auth = AuthResponse.fromJson(
          response.data as Map<String, dynamic>);

      // Persist tokens immediately after registration
      await Future.wait([
        _storage.saveTokens(
          accessToken:  auth.accessToken,
          refreshToken: auth.refreshToken,
        ),
        _storage.saveUserData(jsonEncode(auth.user.toJson())),
      ]);
      return auth;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Sign In ────────────────────────────────────────────────

  Future<AuthResponse> signIn(SignInRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.signIn,
        data: request.toJson(),
      );
      final auth = AuthResponse.fromJson(
          response.data as Map<String, dynamic>);

      await Future.wait([
        _storage.saveTokens(
          accessToken:  auth.accessToken,
          refreshToken: auth.refreshToken,
        ),
        _storage.saveUserData(jsonEncode(auth.user.toJson())),
      ]);
      return auth;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Sign Out ───────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      // Best-effort server-side token invalidation
      await _client.post(AuthEndpoints.signOut);
    } catch (_) {
      // Even if request fails, clear local storage
    } finally {
      await _storage.clearAll();
    }
  }

  // ── Forgot Password ────────────────────────────────────────

  Future<MessageResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.forgotPassword,
        queryParameters: {'email': request.email},
      );
      final data = response.data;
      return MessageResponse.fromJson(
          data is Map<String, dynamic> ? data : {'message': data?.toString() ?? ''});
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.verifyOtp,
        queryParameters: {'email': request.email, 'code': request.otp},
      );
      final data = response.data;
      return VerifyOtpResponse.fromJson(
          data is Map<String, dynamic> ? data : {'message': data?.toString() ?? ''});
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Resend OTP ─────────────────────────────────────────────

  Future<MessageResponse> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.resendOtp,
        data: request.toJson(),
      );
      return MessageResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Reset Password ─────────────────────────────────────────

  Future<MessageResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.resetPassword,
        data: request.toJson(),
      );
      final data = response.data;
      return MessageResponse.fromJson(
          data is Map<String, dynamic> ? data : {'message': data?.toString() ?? ''});
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Change Password (authenticated) ───────────────────────

  Future<MessageResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _client.post(
        AuthEndpoints.changePassword,
        data: request.toJson(),
      );
      return MessageResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Get current user ───────────────────────────────────────

  Future<UserModel> getMe() async {
    try {
      final response = await _client.get(AuthEndpoints.me);
      return UserModel.fromJson(
          response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  // ── Check if session exists locally ───────────────────────

  Future<bool> hasActiveSession() => _storage.hasValidToken();

  // ── Private helpers ────────────────────────────────────────

  /// Unwrap AppException from DioException.error (set by ErrorInterceptor).
  AppException _unwrap(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    return AppException.unknown(e.message);
  }
}
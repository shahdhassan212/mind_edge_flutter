// lib/features/auth/auth_view_model.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/token_storage.dart';
import 'auth_models.dart';
import 'auth_repostiries.dart';

// ── Infrastructure Providers ──────────────────────────────────────────────────
// Moved here so auth_providers.dart can import this file without circular deps.

final dioClientProvider = Provider<DioClient>((_) => DioClient());

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => TokenStorage.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    client: ref.watch(dioClientProvider),
    storage: ref.watch(tokenStorageProvider),
  ),
);

// Watched by the router — invalidated after sign-in / sign-out.
final sessionProvider = FutureProvider<bool>(
  (ref) => ref.watch(tokenStorageProvider).hasValidToken(),
);

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final json = await ref.watch(tokenStorageProvider).getUserData();
  if (json == null || json.isEmpty) return null;
  try {
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

// ── Auth Operation State ──────────────────────────────────────────────────────
// Replaces the entire auth_state.dart (11 event-style classes → 4 data fields).
//
// Rule: fields represent what IS true right now, not what event occurred.
//   isLoading    — a network call is in flight
//   error        — the last operation failed with this exception
//   otpEmail     — set after forgotPassword(); read by the OTP code screen
//   resetToken   — set after verifyOtp(); read by the new-password screen
final class AuthOpState {
  final bool isLoading;
  final AppException? error;
  final String? otpEmail;
  final String? resetToken;

  const AuthOpState({
    this.isLoading = false,
    this.error,
    this.otpEmail,
    this.resetToken,
  });

  AuthOpState copyWith({
    bool? isLoading,
    AppException? error,
    bool clearError = false,
    String? otpEmail,
    String? resetToken,
  }) =>
      AuthOpState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        otpEmail: otpEmail ?? this.otpEmail,
        resetToken: resetToken ?? this.resetToken,
      );
}

// ── AuthViewModel ─────────────────────────────────────────────────────────────
// Single Notifier for all auth operations.
//
// All methods follow one contract:
//   - Set isLoading + clear any stale error before the call.
//   - Return true on success, false on failure (error stored in state.error).
//   - UI awaits the result for one-shot navigation; ref.listen for side effects.
class AuthViewModel extends Notifier<AuthOpState> {
  @override
  AuthOpState build() => const AuthOpState();

  AuthService get _service => ref.read(authServiceProvider);

  // ── Sign In ─────────────────────────────────────────────────────────────────
  Future<bool> signIn(SignInRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.signIn(request);
      ref.invalidate(sessionProvider);
      state = const AuthOpState();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Sign Up ─────────────────────────────────────────────────────────────────
  Future<bool> signUp(SignUpRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.signUp(request);
      state = const AuthOpState();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _service.signOut();
    ref.invalidate(sessionProvider);
    state = const AuthOpState();
  }

  // ── Forgot Password — step 1: send OTP ─────────────────────────────────────
  // Stores otpEmail in state so the subsequent OTP screen can read it.
  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.forgotPassword(request);
      state = AuthOpState(otpEmail: request.email);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Forgot Password — step 2: verify OTP ───────────────────────────────────
  // Stores resetToken in state so the new-password screen can read it.
  Future<bool> verifyOtp(VerifyOtpRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.verifyOtp(request);
      state = state.copyWith(isLoading: false, resetToken: res.resetToken);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Resend OTP (post-signup email verification) ─────────────────────────────
  Future<bool> resendOtp(ResendOtpRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.resendOtp(request);
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Forgot Password — step 3: set new password ─────────────────────────────
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.resetPassword(request);
      state = const AuthOpState();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  // ── Email Verification (after sign-up) ──────────────────────────────────────
  Future<bool> verifyEmail(VerifyOtpRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.verifyOtp(request);
      ref.invalidate(sessionProvider);
      state = const AuthOpState();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  AppException? get lastError => state.error;

  void clearError() => state = state.copyWith(clearError: true);
  void reset() => state = const AuthOpState();
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthOpState>(
  AuthViewModel.new,
);

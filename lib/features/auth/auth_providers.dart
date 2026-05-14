// lib/features/auth/auth_providers.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/kochalo_animation_widget.dart';
import 'auth_models.dart';
import 'auth_view_model.dart';

export 'auth_view_model.dart';

// ── Status enums (consumed by screens via ref.listen) ────────────────────────
enum SignInStatus { success, error }

enum SignUpStatus { success, error }

enum ForgotEmailStatus { success, error }

enum ForgotCodeStatus { otpResent, error }

// ── AuthState hierarchy (consumed by verify_email_screen) ─────────────────────
abstract class AuthState {}

class AuthIdle extends AuthState {}

class AuthLoading extends AuthState {}

class EmailVerified extends AuthState {}

class OtpResent extends AuthState {
  final String message;
  OtpResent(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class SignOutSuccess extends AuthState {}

// ── SignOutNotifier ───────────────────────────────────────────────────────────
class SignOutNotifier extends StateNotifier<AuthState> {
  SignOutNotifier(this._authVM) : super(AuthIdle());

  final AuthViewModel _authVM;

  Future<void> signOut() async {
    state = AuthLoading();
    await _authVM.signOut();
    state = SignOutSuccess();
  }
}

final signOutProvider = StateNotifierProvider.autoDispose<SignOutNotifier, AuthState>(
  (ref) => SignOutNotifier(ref.read(authViewModelProvider.notifier)),
);

// ── VerifyEmailNotifier ───────────────────────────────────────────────────────
class VerifyEmailNotifier extends StateNotifier<AuthState> {
  VerifyEmailNotifier(this._authVM) : super(AuthIdle());

  final AuthViewModel _authVM;

  Future<void> verify({required String email, required String otp}) async {
    state = AuthLoading();
    final success = await _authVM.verifyEmail(VerifyOtpRequest(email: email, otp: otp));
    state =
        success ? EmailVerified() : AuthError(_authVM.lastError?.message ?? 'Verification failed');
  }

  Future<void> resend({required String email}) async {
    state = AuthLoading();
    final success = await _authVM.resendOtp(ResendOtpRequest(email: email));
    state = success
        ? OtpResent('Code resent successfully')
        : AuthError(_authVM.lastError?.message ?? 'Failed to resend code');
  }
}

final verifyEmailProvider = StateNotifierProvider.autoDispose<VerifyEmailNotifier, AuthState>(
  (ref) => VerifyEmailNotifier(ref.read(authViewModelProvider.notifier)),
);

// ═════════════════════════════════════════════════════════════════════════════
// SIGN IN — Form ViewModel
// ═════════════════════════════════════════════════════════════════════════════
class SignInViewModel extends ChangeNotifier {
  SignInViewModel({required AuthViewModel authVM}) : _authVM = authVM {
    emailFocus.addListener(_onEmailFocusChange);
    passwordFocus.addListener(_onPasswordFocusChange);
    emailCtrl.addListener(_onEmailTyping);
  }

  final AuthViewModel _authVM;
  final animKey = GlobalKey<KochaloLoginAnimationWidgetState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool obscurePassword = true;

  SignInStatus? status;
  String? errorMessage;
  bool isLoading = false;

  void resetError() {
    status = null;
    errorMessage = null;
    notifyListeners();
  }

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  String? validate() {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) return 'Please fill in all fields.';
    if (!email.contains('@')) return 'Please enter a valid email.';
    if (password.length < 6) return 'Password must be at least 6 characters.';

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) return 'Password must contain letters and numbers.';

    return null;
  }

  Future<void> signIn() async {
    final err = validate();
    if (err != null) {
      status = SignInStatus.error;
      errorMessage = err;
      notifyListeners();
      return;
    }
    isLoading = true;
    status = null;
    notifyListeners();

    final success = await _authVM.signIn(
      SignInRequest(email: emailCtrl.text.trim(), password: passwordCtrl.text),
    );

    isLoading = false;
    if (success) {
      status = SignInStatus.success;
    } else {
      status = SignInStatus.error;
      errorMessage = _authVM.lastError?.message ?? 'Sign in failed';
    }
    notifyListeners();
  }

  void _onEmailFocusChange() {
    if (emailFocus.hasFocus) {
      animKey.currentState?.onEmailFocus();
    } else {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!passwordFocus.hasFocus) animKey.currentState?.onIdle();
      });
    }
  }

  void _onPasswordFocusChange() {
    if (passwordFocus.hasFocus) {
      animKey.currentState?.onPasswordFocus();
    } else {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!emailFocus.hasFocus) animKey.currentState?.onIdle();
      });
    }
  }

  void _onEmailTyping() => animKey.currentState?.onEmailTyping(emailCtrl.text);

  @override
  void dispose() {
    emailCtrl
      ..removeListener(_onEmailTyping)
      ..dispose();
    passwordCtrl.dispose();
    emailFocus
      ..removeListener(_onEmailFocusChange)
      ..dispose();
    passwordFocus
      ..removeListener(_onPasswordFocusChange)
      ..dispose();
    super.dispose();
  }
}

final signInVMProvider = ChangeNotifierProvider.autoDispose(
  (ref) => SignInViewModel(authVM: ref.read(authViewModelProvider.notifier)),
);

// ═════════════════════════════════════════════════════════════════════════════
// SIGN UP — Form ViewModel
// ═════════════════════════════════════════════════════════════════════════════
class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({required AuthViewModel authVM}) : _authVM = authVM;

  final AuthViewModel _authVM;
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool obscurePassword = true;
  bool termsAccepted = false;
  int passwordStrength = 0;

  SignUpStatus? status;
  String? successEmail;
  String? errorMessage;
  bool isLoading = false;

  void resetError() {
    status = null;
    errorMessage = null;
    notifyListeners();
  }

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleTerms() {
    termsAccepted = !termsAccepted;
    notifyListeners();
  }

  void updatePasswordStrength(String value) {
    int s = 0;
    if (value.length >= 8) s++;
    if (value.contains(RegExp(r'[A-Z]'))) s++;
    if (value.contains(RegExp(r'[0-9]'))) s++;
    if (value.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    passwordStrength = s;
    notifyListeners();
  }

  String? validate() {
    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        passwordCtrl.text.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!emailCtrl.text.contains('@')) return 'Please enter a valid email.';
    if (passwordStrength < 2) return 'Please choose a stronger password.';

    final password = passwordCtrl.text.trim();
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasNumber) return 'Password must contain letters and numbers.';

    if (!termsAccepted) return 'Please accept the Terms of Service.';
    return null;
  }

  SignUpRequest buildRequest() => SignUpRequest(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        passwordConfirmation: passwordCtrl.text,
      );

  Future<void> signUp() async {
    final err = validate();
    if (err != null) {
      status = SignUpStatus.error;
      errorMessage = err;
      notifyListeners();
      return;
    }
    isLoading = true;
    status = null;
    notifyListeners();

    final request = buildRequest();
    final success = await _authVM.signUp(request);

    isLoading = false;
    if (success) {
      successEmail = request.email;
      status = SignUpStatus.success;
    } else {
      status = SignUpStatus.error;
      errorMessage = _authVM.lastError?.message ?? 'Sign up failed';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}

final signUpVMProvider = ChangeNotifierProvider.autoDispose(
  (ref) => SignUpViewModel(authVM: ref.read(authViewModelProvider.notifier)),
);

// ═════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD — Email Form ViewModel
// ═════════════════════════════════════════════════════════════════════════════
class ForgotPasswordEmailViewModel extends ChangeNotifier {
  ForgotPasswordEmailViewModel({required AuthViewModel authVM}) : _authVM = authVM;

  final AuthViewModel _authVM;
  final emailCtrl = TextEditingController();

  ForgotEmailStatus? status;
  String? sentEmail;
  String? errorMessage;
  bool isLoading = false;

  void resetStatus() {
    status = null;
    sentEmail = null;
    errorMessage = null;
    notifyListeners();
  }

  String? validate() {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return 'Please enter your email.';
    if (!email.contains('@')) return 'Please enter a valid email.';
    return null;
  }

  Future<void> send() async {
    final err = validate();
    if (err != null) {
      status = ForgotEmailStatus.error;
      errorMessage = err;
      notifyListeners();
      return;
    }
    isLoading = true;
    status = null;
    notifyListeners();

    final email = emailCtrl.text.trim();
    final success = await _authVM.forgotPassword(ForgotPasswordRequest(email: email));

    isLoading = false;
    if (success) {
      sentEmail = email;
      status = ForgotEmailStatus.success;
    } else {
      status = ForgotEmailStatus.error;
      errorMessage = _authVM.lastError?.message ?? 'Failed to send code';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }
}

final forgotEmailVMProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ForgotPasswordEmailViewModel(
    authVM: ref.read(authViewModelProvider.notifier),
  ),
);

// ═════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD — OTP Code Form ViewModel
// ═════════════════════════════════════════════════════════════════════════════
class ForgotPasswordCodeViewModel extends ChangeNotifier {
  ForgotPasswordCodeViewModel({required this.email, required AuthViewModel authVM})
      : _authVM = authVM {
    _startTimer();
    for (final n in focusNodes) {
      n.addListener(notifyListeners);
    }
  }

  final String email;
  final AuthViewModel _authVM;

  final List<TextEditingController> otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 8 * 60 + 34;
  Timer? _timer;

  ForgotCodeStatus? status;
  String? successMessage;
  String? errorMessage;
  bool isLoading = false;

  void resetStatus() {
    status = null;
    successMessage = null;
    errorMessage = null;
    notifyListeners();
  }

  String get otp => otpCtrls.map((c) => c.text).join();
  bool get timerExpired => _seconds == 0;
  String get timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void onOtpChanged(int index, String value) {
    notifyListeners();
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> resend() async {
    isLoading = true;
    status = null;
    notifyListeners();

    final success = await _authVM.forgotPassword(ForgotPasswordRequest(email: email));

    isLoading = false;
    if (success) {
      _resetTimer();
      status = ForgotCodeStatus.otpResent;
      successMessage = 'Code resent successfully';
    } else {
      status = ForgotCodeStatus.error;
      errorMessage = _authVM.lastError?.message ?? 'Failed to resend code';
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _seconds = 8 * 60 + 34;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in otpCtrls) {
      c.dispose();
    }
    for (final n in focusNodes) {
      n.removeListener(notifyListeners);
      n.dispose();
    }
    super.dispose();
  }
}

final forgotCodeVMProvider =
    ChangeNotifierProvider.autoDispose.family<ForgotPasswordCodeViewModel, String>(
  (ref, email) => ForgotPasswordCodeViewModel(
    email: email,
    authVM: ref.read(authViewModelProvider.notifier),
  ),
);

// ═════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD — New Password Form ViewModel
// ═════════════════════════════════════════════════════════════════════════════
enum ResetPassStatus { success, error }

class ForgotPasswordNewPassViewModel extends ChangeNotifier {
  ForgotPasswordNewPassViewModel({required AuthViewModel authVM}) : _authVM = authVM {
    newPassCtrl.addListener(_calcStrength);
  }

  final AuthViewModel _authVM;
  final newPassCtrl = TextEditingController();
  final confPassCtrl = TextEditingController();
  bool obscureNew = true;
  bool obscureConf = true;
  int strength = 0;

  ResetPassStatus? status;
  String? errorMessage;
  bool isLoading = false;

  void resetStatus() {
    status = null;
    errorMessage = null;
    notifyListeners();
  }

  void toggleObscureNew() {
    obscureNew = !obscureNew;
    notifyListeners();
  }

  void toggleObscureConf() {
    obscureConf = !obscureConf;
    notifyListeners();
  }

  void _calcStrength() {
    final p = newPassCtrl.text;
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    strength = s;
    notifyListeners();
  }

  String? validate() {
    final pw = newPassCtrl.text;
    final conf = confPassCtrl.text;
    if (pw.isEmpty || conf.isEmpty) return 'Please fill in both fields.';
    if (pw != conf) return 'Passwords do not match.';
    if (strength < 2) return 'Please choose a stronger password.';
    return null;
  }

  Future<void> submit({required String email, required String code}) async {
    final err = validate();
    if (err != null) {
      status = ResetPassStatus.error;
      errorMessage = err;
      notifyListeners();
      return;
    }
    isLoading = true;
    status = null;
    notifyListeners();

    final success = await _authVM.resetPassword(
      ResetPasswordRequest(
        email: email,
        code: code,
        newPassword: newPassCtrl.text,
      ),
    );

    isLoading = false;
    if (success) {
      status = ResetPassStatus.success;
    } else {
      status = ResetPassStatus.error;
      errorMessage = _authVM.lastError?.message ?? 'Failed to reset password';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    newPassCtrl
      ..removeListener(_calcStrength)
      ..dispose();
    confPassCtrl.dispose();
    super.dispose();
  }
}

final forgotNewPassVMProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ForgotPasswordNewPassViewModel(
    authVM: ref.read(authViewModelProvider.notifier),
  ),
);
class VerifyEmailViewModel extends ChangeNotifier {
  VerifyEmailViewModel({required this.email, required AuthViewModel authVM}) : _authVM = authVM {
    for (final n in focusNodes) {
      n.addListener(notifyListeners);
    }
  }

  final String email;
  final AuthViewModel _authVM;

  final List<TextEditingController> otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String get otp => otpCtrls.map((c) => c.text).join();

  void onOtpChanged(int index, String value) {
    notifyListeners();
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> resend() => _authVM.resendOtp(ResendOtpRequest(email: email));

  @override
  void dispose() {
    for (final c in otpCtrls) {
      c.dispose();
    }
    for (final n in focusNodes) {
      n.removeListener(notifyListeners);
      n.dispose();
    }
    super.dispose();
  }
}

final verifyEmailVMProvider =
    ChangeNotifierProvider.autoDispose.family<VerifyEmailViewModel, String>(
  (ref, email) => VerifyEmailViewModel(
    email: email,
    authVM: ref.read(authViewModelProvider.notifier),
  ),
);
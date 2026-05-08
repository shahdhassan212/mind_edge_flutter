// ============================================================
// core/constants/api_endpoints.dart
//
// SINGLE SOURCE OF TRUTH for every URL in the app.
// ─────────────────────────────────────────────────────────────
// HOW TO REPLACE ENDPOINTS LATER:
//   1. Change kBaseUrl to your production URL.
//   2. Update only the path string next to each endpoint.
//   3. Nothing in services, providers, or UI needs to change.
// ============================================================

// ── Base URL ──────────────────────────────────────────────────
const String kBaseUrl = 'https://midedge.runasp.net';

// ── Timeouts ──────────────────────────────────────────────────
const Duration kConnectTimeout = Duration(seconds: 15);
const Duration kReceiveTimeout = Duration(seconds: 30);
const Duration kSendTimeout = Duration(seconds: 20);

// ── Header keys ───────────────────────────────────────────────
const String kHeaderContentType = 'Content-Type';
const String kHeaderAccept = 'Accept';
const String kHeaderAuthorization = 'Authorization';
const String kContentTypeJson = 'application/json';
const String kTokenPrefix = 'Bearer';

// ── Secure storage keys ───────────────────────────────────────
const String kStorageAccessToken = 'access_token';
const String kStorageRefreshToken = 'refresh_token';
const String kStorageUserData = 'user_data';

// ============================================================
// AUTH ENDPOINTS
// ============================================================
class AuthEndpoints {
  AuthEndpoints._();

  /// POST { first_name, last_name, email, password, password_confirmation }
  static const String signUp = '/api/Auth/register';

  /// POST { email, password }
  static const String signIn = '/api/Auth/login';

  /// POST { email }
  static const String forgotPassword = '/api/Auth/forgot-password';

  /// POST { email, token } — email verification / OTP
  static const String verifyOtp = '/api/Auth/verify-email';

  /// POST { reset_token, password, password_confirmation }
  static const String resetPassword = '/api/Auth/reset-password';

  static const String signOut = '/api/Auth/logout';
  static const String resendOtp = '/api/Auth/resend-otp';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String me = '/api/Auth/me';
  static const String changePassword = '/api/Auth/change-password';
}

// ============================================================
// FILE ENDPOINTS
// ============================================================
class FileEndpoints {
  FileEndpoints._();

  static const String upload = '/api/File/Upload';
  static const String download = '/api/File/Download';
  static const String listFiles = '/api/File/ListFiles';
}

// ============================================================
// STUDY PLAN ENDPOINTS  (expand as backend grows)
// ============================================================
class StudyPlanEndpoints {
  StudyPlanEndpoints._();

  static const String create = '/study-plans';
  static const String getAll = '/study-plans';
  static String byId(String id) => '/study-plans/$id';
}

// ============================================================
// DOCUMENT / OCR ENDPOINTS
// ============================================================
class DocumentEndpoints {
  DocumentEndpoints._();

  static const String upload = '/documents/upload';
  static const String getAll = '/documents';
  static String byId(String id) => '/documents/$id';

  /// POST multipart/form-data  field: 'file'
  static const String analyzeFile = '/Document/analyze';

  /// GET — returns { filename, summary }
  static const String summary = '/Document/summary';

  /// GET — returns { rules: [...] }
  static const String getRules = '/Document/get-rules';

  /// GET — returns { definitions: [...] }
  static const String getDefinitions = '/Document/get-definitions';
}

// ============================================================
// QUIZ ENDPOINTS
// ============================================================
class QuizEndpoints {
  QuizEndpoints._();

  static const String generate = '/quizzes/generate';
  static String submit(String id) => '/quizzes/$id/submit';
  static String results(String id) => '/quizzes/$id/results';
}

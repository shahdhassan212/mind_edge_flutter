const String kBaseUrl = 'https://midedge.runasp.net';

const Duration kConnectTimeout = Duration(seconds: 15);
const Duration kReceiveTimeout = Duration(seconds: 30);
const Duration kSendTimeout = Duration(seconds: 20);

const String kHeaderContentType = 'Content-Type';
const String kHeaderAccept = 'Accept';
const String kHeaderAuthorization = 'Authorization';
const String kContentTypeJson = 'application/json';
const String kTokenPrefix = 'Bearer';

const String kStorageAccessToken = 'access_token';
const String kStorageRefreshToken = 'refresh_token';
const String kStorageUserData = 'user_data';

class AuthEndpoints {
  AuthEndpoints._();

  static const String signUp = '/api/Auth/register';

  static const String signIn = '/api/Auth/login';

  static const String forgotPassword = '/api/Auth/forgot-password';

  static const String verifyOtp = '/api/Auth/verify-email';

  static const String resetPassword = '/api/Auth/reset-password';

  static const String signOut = '/api/Auth/logout';
  static const String resendOtp = '/api/Auth/resend-otp';
  static const String refreshToken = '/api/Auth/refresh-token';
  static const String me = '/api/Auth/me';
  static const String changePassword = '/api/Auth/change-password';
}

class FileEndpoints {
  FileEndpoints._();

  static const String upload = '/api/File/Upload';
  static const String download = '/api/File/Download';
  static const String listFiles = '/api/File/ListFiles';
}

class StudyPlanEndpoints {
  StudyPlanEndpoints._();

  static const String create = '/study-plans';
  static const String getAll = '/study-plans';
  static String byId(String id) => '/study-plans/$id';
}

class DocumentEndpoints {
  DocumentEndpoints._();

  static const String upload = '/documents/upload';
  static const String getAll = '/documents';
  static String byId(String id) => '/documents/$id';
  static const String analyzeFile = '/Document/analyze';
  static const String summary = '/Document/summary';
  static const String getRules = '/Document/get-rules';
  static const String getDefinitions = '/Document/get-definitions';
}

class QuizEndpoints {
  QuizEndpoints._();

  static const String generate = '/quizzes/generate';
  static String submit(String id) => '/quizzes/$id/submit';
  static String results(String id) => '/quizzes/$id/results';
}

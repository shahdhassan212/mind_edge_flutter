// core/errors/app_exception.dart
enum ExceptionType {
  noInternet,
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  cancelled,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  badRequest,
  invalidCredentials,
  emailAlreadyExists,
  invalidOtp,
  expiredOtp,
  tokenExpired,
  tokenInvalid,
  weakPassword,
  parseError,
  unknown,
}

class AppException implements Exception {
  final ExceptionType type;
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final int? statusCode;

  const AppException({
    required this.type,
    required this.message,
    this.fieldErrors,
    this.statusCode,
  });

  factory AppException.noInternet() => const AppException(
        type: ExceptionType.noInternet,
        message: 'No internet connection. Please check your network.',
      );
  factory AppException.timeout() => const AppException(
        type: ExceptionType.connectionTimeout,
        message: 'Connection timed out. Please try again.',
      );
  factory AppException.unauthorized() => const AppException(
        type: ExceptionType.unauthorized,
        message: 'Session expired. Please sign in again.',
        statusCode: 401,
      );
  factory AppException.invalidCredentials() => const AppException(
        type: ExceptionType.invalidCredentials,
        message: 'Wrong credentials.',
        statusCode: 401,
      );
  factory AppException.serverError([int? code]) => AppException(
        type: ExceptionType.serverError,
        message: 'Something went wrong. Please try again later.',
        statusCode: code,
      );
  factory AppException.unknown([String? msg]) => AppException(
        type: ExceptionType.unknown,
        message: msg ?? 'An unexpected error occurred.',
      );

  bool get isNetworkError =>
      type == ExceptionType.noInternet || type == ExceptionType.connectionTimeout;

  bool get isAuthError =>
      type == ExceptionType.unauthorized ||
      type == ExceptionType.invalidCredentials ||
      type == ExceptionType.tokenExpired;

  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  @override
  String toString() => 'AppException(type: $type, status: $statusCode, msg: $message)';
}

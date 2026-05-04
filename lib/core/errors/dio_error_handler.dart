// core/errors/dio_error_handler.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'app_exception.dart';

class DioErrorHandler {
  DioErrorHandler._();

  static AppException handle(Object error) {
    if (error is DioException) return _fromDio(error);
    if (error is AppException) return error;
    return AppException.unknown(error.toString());
  }

  static AppException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout();
      case DioExceptionType.connectionError:
        return _fromConnectionError(e);
      case DioExceptionType.cancel:
        return AppException(type: ExceptionType.cancelled, message: 'Cancelled.');
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      default:
        final msg = e.message ?? '';
        if (msg.toLowerCase().contains('socket') || msg.toLowerCase().contains('network')) {
          return AppException.noInternet();
        }
        return AppException.unknown(msg);
    }
  }

  static AppException _fromConnectionError(DioException e) {
    final inner = e.error;

    // SSL / TLS / certificate error
    if (inner is HandshakeException || inner is CertificateException) {
      return const AppException(
        type: ExceptionType.serverError,
        message: 'Secure connection failed. Please try again later.',
      );
    }

    if (inner is SocketException) {
      final msg = inner.message.toLowerCase();
      // DNS / host lookup failure → server is unreachable, not a device network issue
      if (msg.contains('failed host lookup') ||
          msg.contains('nodename nor servname') ||
          msg.contains('no address associated') ||
          msg.contains('connection refused')) {
        return AppException.serverError();
      }
    }

    // Check if the error message hints at SSL
    final errMsg = (e.message ?? '').toLowerCase();
    if (errMsg.contains('certificate') ||
        errMsg.contains('handshake') ||
        errMsg.contains('ssl') ||
        errMsg.contains('tls')) {
      return const AppException(
        type: ExceptionType.serverError,
        message: 'Secure connection failed. Please try again later.',
      );
    }

    return AppException.noInternet();
  }

  static AppException _fromResponse(Response? r) {
    if (r == null) return AppException.serverError();
    final code = r.statusCode ?? 0;
    final body = r.data;
    final msg = _extractMessage(body);

    switch (code) {
      case 400:
        return AppException(
          type: ExceptionType.badRequest,
          message: msg.isNotEmpty ? msg : 'Invalid request.',
          statusCode: code,
          fieldErrors: _extractFieldErrors(body),
        );
      case 401:
        final lower = msg.toLowerCase();
        if (lower.contains('expired')) {
          return AppException(
              type: ExceptionType.tokenExpired,
              message: 'Session expired. Please sign in again.',
              statusCode: 401);
        }
        return AppException.invalidCredentials();
      case 403:
        return AppException(
            type: ExceptionType.forbidden, message: 'Access denied.', statusCode: 403);
      case 404:
        return AppException(
            type: ExceptionType.notFound,
            message: msg.isNotEmpty ? msg : 'Not found.',
            statusCode: 404);
      case 409:
        return AppException(
            type: ExceptionType.emailAlreadyExists,
            message: msg.isNotEmpty ? msg : 'Email is already registered.',
            statusCode: 409);
      case 422:
        return AppException(
            type: ExceptionType.validationError,
            message: msg.isNotEmpty ? msg : 'Please check the fields.',
            statusCode: 422,
            fieldErrors: _extractFieldErrors(body));
      case 429:
        return AppException(
            type: ExceptionType.unknown,
            message: 'Too many attempts. Please wait.',
            statusCode: 429);
      default:
        if (code >= 500) return AppException.serverError(code);
        return AppException.unknown(msg);
    }
  }

  static String _extractMessage(dynamic body) {
    if (body == null) return '';
    if (body is String) return body;
    if (body is Map<String, dynamic>) {
      return body['message']?.toString() ??
          body['error']?.toString() ??
          body['title']?.toString() ??
          body['detail']?.toString() ??
          '';
    }
    return '';
  }

  static Map<String, List<String>>? _extractFieldErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    // ASP.NET validation: { "errors": { "Email": ["..."] } }
    // or: { "Email": ["..."] }
    final errors = body['errors'] ?? body;
    if (errors is! Map<String, dynamic>) return null;
    final result = <String, List<String>>{};
    for (final e in errors.entries) {
      if (e.value is List) {
        result[e.key] = List<String>.from((e.value as List).map((x) => x.toString()));
      } else if (e.value is String) {
        result[e.key] = [e.value as String];
      }
    }
    return result.isEmpty ? null : result;
  }
}

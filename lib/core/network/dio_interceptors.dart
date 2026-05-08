// ============================================================
// core/network/dio_interceptors.dart
// ============================================================

import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import '../api_endpoints.dart';
import '../errors/dio_error_handler.dart';
import '../token_storage.dart';

// ── 1. Auth Interceptor ───────────────────────────────────────
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;

  AuthInterceptor(this._dio, this._storage);

  // Endpoints that do NOT need a token attached
  static const _publicPaths = {
    AuthEndpoints.signIn,
    AuthEndpoints.signUp,
    AuthEndpoints.forgotPassword,
    AuthEndpoints.verifyOtp,
    AuthEndpoints.resendOtp,
    AuthEndpoints.resetPassword,
    AuthEndpoints.refreshToken,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicPaths.contains(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[kHeaderAuthorization] = '$kTokenPrefix $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isProtected = !_publicPaths.contains(err.requestOptions.path);

    if (is401 && isProtected) {
      try {
        final newToken = await _tryRefresh();
        if (newToken != null) {
          // Retry original request with new token
          final opts = err.requestOptions;
          opts.headers[kHeaderAuthorization] = '$kTokenPrefix $newToken';
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        }
        // Refresh succeeded but returned no token → session truly expired
        await _storage.clearAll();
      } on DioException catch (e) {
        // Only clear session if the refresh endpoint itself rejected us (401/403)
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          await _storage.clearAll();
        }
        // Network/server errors during refresh → keep tokens, forward original error
      } catch (_) {
        // Unknown error during refresh → keep tokens, forward original error
      }
    }
    handler.next(err);
  }

  Future<String?> _tryRefresh() async {
    final accessToken = await _storage.getAccessToken();
    final refreshToken = await _storage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return null;

    // Separate Dio to avoid interceptor loop
    final plainDio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        kHeaderContentType: kContentTypeJson,
        kHeaderAccept: kContentTypeJson,
      },
    ));

    final res = await plainDio.post(
      AuthEndpoints.refreshToken,
      // ASP.NET Identity refresh body: token + refreshToken
      data: {
        'token': accessToken,
        'refreshToken': refreshToken,
      },
    );

    // ASP.NET returns: { token, refreshToken, expiration }
    final newAccess = res.data['token']?.toString();
    final newRefresh = res.data['refreshToken']?.toString();

    if (newAccess != null && newAccess.isNotEmpty) {
      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? refreshToken,
      );
    }
    return newAccess;
  }
}

// ── 2. Error Interceptor ──────────────────────────────────────
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appEx = DioErrorHandler.handle(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: appEx,
        response: err.response,
        type: err.type,
        message: appEx.message,
      ),
    );
  }
}

// ── 3. Logging Interceptor ────────────────────────────────────
class LoggingInterceptor extends Interceptor {
  static const _tag = 'MINDEDGE';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final body = options.data;
    final bodyDesc = body is FormData
        ? 'FormData(fields: ${body.fields.map((f) => f.key).toList()}, '
            'files: ${body.files.map((f) => "${f.key}=${f.value.filename}").toList()})'
        : '$body';
    dev.log('→ ${options.method} ${options.uri}\n  body: $bodyDesc', name: _tag);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log('← ${response.statusCode} ${response.requestOptions.uri}', name: _tag);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log(
      '✗ [${err.response?.statusCode}] ${err.requestOptions.uri}\n'
      '  ${err.message}\n'
      '  response.data: ${err.response?.data}',
      name: _tag,
      error: err.error,
    );
    print('❌ [${err.response?.statusCode}] ${err.requestOptions.uri} → ${err.response?.data}');
    handler.next(err);
  }
}

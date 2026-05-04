// core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../api_endpoints.dart';
import '../token_storage.dart';
import 'dio_interceptors.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: kConnectTimeout,
      receiveTimeout: kReceiveTimeout,
      sendTimeout: kSendTimeout,
      headers: {
        kHeaderContentType: kContentTypeJson,
        kHeaderAccept: kContentTypeJson,
      },
      validateStatus: (s) => s != null && s < 300,
    ));

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(_dio, TokenStorage.instance),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? queryParameters, Options? options}) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) =>
      _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );

  Future<Response<T>> put<T>(String path, {dynamic data, Options? options}) =>
      _dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(String path, {dynamic data, Options? options}) =>
      _dio.delete<T>(path, data: data, options: options);
}

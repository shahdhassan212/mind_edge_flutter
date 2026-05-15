// features/analysis/repository/quiz_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/quiz_models.dart';

class QuizRepository {
  final DioClient _client;

  const QuizRepository({required DioClient client}) : _client = client;

  Dio get _dio => _client.dio;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw FormatException('Expected JSON object, got: ${decoded.runtimeType}');
    }
    throw FormatException('Unexpected response type: ${data.runtimeType}');
  }

  // ── POST /api/Quiz/generate ───────────────────────────────
  Future<QuizGenerateResponse> generateQuiz({
    required String filename,
    required int numQuestions,
    required QuizType quizType,
  }) async {
    final body = QuizGenerateRequest(
      filename: filename,
      numQuestions: numQuestions,
      quizType: quizType,
    ).toJson();

    final resp = await _dio.post(
      '/api/Quiz/generate',
      data: body,
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return QuizGenerateResponse.fromJson(_asJsonMap(resp.data));
  }

  // ── POST /api/Quiz/submit ─────────────────────────────────
  Future<QuizSubmitResponse> submitQuiz({
    required String quizId,
    required List<String> answers,
  }) async {
    final body = QuizSubmitRequest(quizId: quizId, answers: answers).toJson();

    final resp = await _dio.post(
      '/api/Quiz/submit',
      data: body,
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return QuizSubmitResponse.fromJson(_asJsonMap(resp.data));
  }
}

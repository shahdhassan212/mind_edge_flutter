import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/analysis_models.dart';

class AnalysisRepository {
  final DioClient _client;

  const AnalysisRepository({required DioClient client}) : _client = client;

  Dio get _dio => _client.dio;

  // ── Safe JSON map cast ────────────────────────────────────
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

  // ── POST /api/Document/analyze-visuals ───────────────────
  Future<VisualAnalysisModel> analyzeVisuals(File file) async {
    final filename = file.path.split(RegExp(r'[\\/]+')).last;

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: filename),
    });

    final resp = await _dio.post(
      '/api/Document/analyze-visuals',
      data: formData,
      options: Options(
        headers: {'accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    return VisualAnalysisModel.fromJson(_asJsonMap(resp.data));
  }

  // ── POST /api/Document/summary ─────────────────────
  Future<AudioSummaryModel> processAudio(
    String fileName, {
    bool tts = true,
  }) async {
    final resp = await _dio.post(
      '/api/Document/summary', // تم تغيير المسار من process-audio إلى summary
      queryParameters: {'fileName': fileName, 'tts': tts},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return AudioSummaryModel.fromJson(_asJsonMap(resp.data));
  }

  // ── GET /api/Document/get-rules ──────────────────────────
  // Response shape:
  //   { "rules": "<JSON-encoded string>" }
  // The inner string is itself a JSON object:
  //   { "filename": "...", "rules": "<markdown or rule text>" }
  Future<RulesModel> fetchRules(String filename) async {
    final resp = await _dio.get(
      '/api/Document/get-rules',
      queryParameters: {'filename': filename},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    final outer = _asJsonMap(resp.data);

    // The value of "rules" key is a JSON-encoded string — decode it
    final innerRaw = outer['rules'];
    final inner = _asJsonMap(innerRaw); // handles both String and Map

    return RulesModel.fromJson(inner);
  }

  // ── GET /api/Document/get-definitions ────────────────────
  // Response shape:
  //   { "definitions": "<JSON-encoded string>" }
  // The inner string is itself a JSON object:
  //   { "filename": "...", "definitions": "<markdown string>" }
  Future<DefinitionsModel> fetchDefinitions(String filename) async {
    final resp = await _dio.get(
      '/api/Document/get-definitions',
      queryParameters: {'filename': filename},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    final outer = _asJsonMap(resp.data);

    // The value of "definitions" key is a JSON-encoded string — decode it
    final innerRaw = outer['definitions'];
    final inner = _asJsonMap(innerRaw);

    return DefinitionsModel.fromJson(inner);
  }
}

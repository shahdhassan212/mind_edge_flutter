import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/analysis_models.dart';

class AnalysisRepository {
  final DioClient _client;

  const AnalysisRepository({required DioClient client}) : _client = client;

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
        headers: {"accept": "application/json"},
        responseType: ResponseType.json,
      ),
    );

    return VisualAnalysisModel.fromJson(_asJsonMap(resp.data));
  }

  // ── POST /api/Document/process-audio ─────────────────────
  // fileName = the document_name returned from analyze-visuals
  Future<AudioSummaryModel> processAudio(String fileName) async {
    final resp = await _dio.post(
      '/api/Document/process-audio',
      queryParameters: {'fileName': fileName},
      options: Options(
        headers: {"accept": "application/json"},
        responseType: ResponseType.json,
      ),
    );

    return AudioSummaryModel.fromJson(_asJsonMap(resp.data));
  }

  // ── Formula extraction (placeholder → swap when ready) ───
  Future<List<FormulaItem>> fetchFormulas(String fileId) async {
    // TODO: uncomment when AI team delivers /api/AI/ExtractFormulas
    // final resp = await _dio.post<Map<String, dynamic>>(
    //   '/api/AI/ExtractFormulas',
    //   data: {'fileId': fileId},
    // );
    // return (resp.data!['formulas'] as List)
    //     .map((e) => FormulaItem.fromJson(e))
    //     .toList();
    await Future.delayed(const Duration(milliseconds: 500));
    return FormulaItem.placeholders();
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
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
  Future<RulesModel> fetchRules(String filename) async {
    final resp = await _dio.get(
      '/api/Document/get-rules',
      queryParameters: {'filename': filename},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    // Response is now a flat JSON object: { "filename": "...", "rules": "..." }
    return RulesModel.fromJson(_asJsonMap(resp.data));
  }

  // ── GET /api/Document/get-definitions ────────────────────
  Future<DefinitionsModel> fetchDefinitions(String filename) async {
    final resp = await _dio.get(
      '/api/Document/get-definitions',
      queryParameters: {'filename': filename},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    // Response is now a flat JSON object: { "filename": "...", "definitions": "..." }
    return DefinitionsModel.fromJson(_asJsonMap(resp.data));
  }

  // ── POST /api/Document/DownloadSummaryPdf ────────────────
  Future<File> downloadSummaryPdf({
    required String title,
    required AnalysisState state,
  }) async {
    final buffer = StringBuffer();
    final divider = '=' * 50;
    final subDivider = '-' * 40;

    // ── Header
    buffer.writeln(divider);
    buffer.writeln('  $title');
    buffer.writeln('  AI Analysis Report');
    buffer.writeln(divider);
    buffer.writeln();

    // ── Summary
    if (state.summaryData?.summary.isNotEmpty == true) {
      buffer.writeln('SUMMARY');
      buffer.writeln(subDivider);
      // Strip markdown symbols for cleaner PDF text
      final summary = state.summaryData!.summary
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
          .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')
          .replaceAll(RegExp(r'^#{1,3}\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '  • ');
      buffer.writeln(summary.trim());
      buffer.writeln();
    }

    // ── Rules
    if (state.rulesData?.rawRules.isNotEmpty == true) {
      buffer.writeln('RULES & FORMULAS');
      buffer.writeln(subDivider);
      final rules = state.rulesData!.rawRules
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
          .replaceAll(RegExp(r'`(.+?)`'), r'[\1]')
          .replaceAll(RegExp(r'^#{1,3}\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '  • ');
      buffer.writeln(rules.trim());
      buffer.writeln();
    }

    // ── Definitions
    if (state.definitionsData?.markdownContent.isNotEmpty == true) {
      buffer.writeln('KEY DEFINITIONS');
      buffer.writeln(subDivider);
      final defs = state.definitionsData!.markdownContent
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
          .replaceAll(RegExp(r'^#{1,3}\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '  ')
          .replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '    - ');
      buffer.writeln(defs.trim());
      buffer.writeln();
    }

    // ── Visual Analysis
    if (state.visualData?.correctedText.isNotEmpty == true) {
      buffer.writeln('VISUAL ANALYSIS');
      buffer.writeln(subDivider);
      final analysis = state.visualData!.correctedText
          .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
          .replaceAll(RegExp(r'^#{1,3}\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^[-•]\s+', multiLine: true), '  • ');
      buffer.writeln(analysis.trim());
      buffer.writeln();
    }

    buffer.writeln(divider);

    final resp = await _dio.post(
      '/api/Document/DownloadSummaryPdf',
      data: {'title': title, 'content': buffer.toString()},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.bytes,
      ),
    );

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${title}_Summary.pdf';
    final file = File(filePath);
    await file.writeAsBytes(resp.data as List<int>);
    return file;
  }
}

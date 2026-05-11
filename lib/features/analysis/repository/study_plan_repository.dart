// features/study_plan/repository/study_plan_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/study_plan_models.dart';

class StudyPlanRepository {
  final DioClient _client;

  const StudyPlanRepository({required DioClient client}) : _client = client;

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

  // ── POST /api/StudyPlan/generate?filename=xxx ─────────────
  Future<StudyPlanResponse> generatePlan({
    required String filename,
    required int days,
    required int hoursPerDay,
    required String level,
  }) async {
    final body = StudyPlanGenerateRequest(
      days: days,
      hoursPerDay: hoursPerDay,
      level: level,
    ).toJson();

    final resp = await _dio.post(
      '/api/StudyPlan/generate',
      queryParameters: {'filename': filename},
      data: body,
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return StudyPlanResponse.fromJson(_asJsonMap(resp.data));
  }

  // ── GET /api/StudyPlan/dashboard ──────────────────────────
  Future<List<DashboardTask>> fetchDashboard() async {
    final resp = await _dio.get(
      '/api/StudyPlan/dashboard',
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    final list = resp.data as List<dynamic>? ?? [];
    return list
        .map((t) => DashboardTask.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/StudyPlan/archive-names ─────────────────────
  Future<List<PlanArchiveItem>> fetchArchiveNames() async {
    final resp = await _dio.get(
      '/api/StudyPlan/archive-names',
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    final list = resp.data as List<dynamic>? ?? [];
    return list
        .map((t) => PlanArchiveItem.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/StudyPlan/plan-by-file?fileName=xxx ─────────
  Future<StudyPlanResponse> fetchPlanByFile(String fileName) async {
    final resp = await _dio.get(
      '/api/StudyPlan/plan-by-file',
      queryParameters: {'fileName': fileName},
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return StudyPlanResponse.fromJson(_asJsonMap(resp.data));
  }

  // ── PATCH /api/StudyPlan/tasks/{id}/toggle ────────────────
  Future<void> toggleTask(int taskId) async {
    await _dio.patch(
      '/api/StudyPlan/tasks/$taskId/toggle',
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );
  }
}
// features/analysis/repository/chat_repository.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/chat_models.dart';

class ChatRepository {
  final DioClient _client;

  const ChatRepository({required DioClient client}) : _client = client;

  Dio get _dio => _client.dio;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    }
    throw Exception('Unexpected response format');
  }

  // ── POST /api/Chat/send ──────────────────────────────────
  Future<ChatResponseModel> sendMessage({
    required String question,
    required String filename,
    String? sessionId,
    required bool tts,
  }) async {
    final body = ChatRequestModel(
      question: question,
      filename: filename,
      sessionId: sessionId,
      tts: tts,
    ).toJson();

    final resp = await _dio.post(
      '/api/Chat/send',
      data: body,
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return ChatResponseModel.fromJson(_asJsonMap(resp.data));
  }

  // ── GET /api/Chat/my-chats ────────────────────────────────
  Future<List<ChatSession>> fetchMyChats() async {
    final resp = await _dio.get(
      '/api/Chat/my-chats',
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );
    final list = resp.data as List<dynamic>? ?? [];
    return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── GET /api/Chat/history/{sessionId} ────────────────────
  Future<List<ChatHistoryMessage>> fetchHistory(String sessionId) async {
    final resp = await _dio.get(
      '/api/Chat/history/$sessionId',
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    final list = resp.data as List<dynamic>? ?? [];
    return list.map((e) => ChatHistoryMessage.fromJson(e as Map<String, dynamic>)).toList();
  }
}

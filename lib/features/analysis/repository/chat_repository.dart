import 'dart:convert';
import '../../../core/network/dio_client.dart';
import '../model/chat_models.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final DioClient _client;

  ChatRepository({required DioClient client}) : _client = client;

  Dio get _dio => _client.dio;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    }
    throw Exception("Unexpected response format");
  }

  Future<ChatResponseModel> sendMessage({
    required String question,
    String? sessionId,
    required bool tts,
  }) async {
    // تجهيز الـ parameters وحذف الـ sessionId إذا كان null
    final Map<String, dynamic> params = {
      "question": question,
      "tts": tts,
    };
    
    if (sessionId != null && sessionId.isNotEmpty) {
      params["sessionId"] = sessionId;
    }

    final resp = await _dio.post(
      '/api/Chat/chat',
      queryParameters: params,
      options: Options(
        headers: {'accept': '*/*'},
        responseType: ResponseType.json,
      ),
    );

    return ChatResponseModel.fromJson(_asJsonMap(resp.data));
  }
}
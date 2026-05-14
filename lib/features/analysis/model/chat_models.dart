// features/analysis/model/chat_models.dart

// ── Send request ──────────────────────────────────────────────
class ChatRequestModel {
  final String question;
  final String? sessionId;
  final String filename;
  final bool tts;
  final String ttsSource;

  const ChatRequestModel({
    required this.question,
    this.sessionId,
    required this.filename,
    required this.tts,
    this.ttsSource = 'openai',
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        if (sessionId != null && sessionId!.isNotEmpty) 'session_id': sessionId,
        'filename': filename,
        'tts': tts,
        'tts_source': ttsSource,
      };
}

// ── Send response ─────────────────────────────────────────────
class ChatResponseModel {
  final String answer;
  final String? audioUrl;
  final String sessionId;

  const ChatResponseModel({
    required this.answer,
    required this.sessionId,
    this.audioUrl,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) => ChatResponseModel(
        answer: json['answer']?.toString() ?? '',
        audioUrl: json['audio_url']?.toString(),
        sessionId: json['session_id']?.toString() ?? '',
      );
}

// ── Chat session (my-chats) ───────────────────────────────────
class ChatSession {
  final String sessionId;
  final String title;
  final DateTime lastMessageDate;

  const ChatSession({
    required this.sessionId,
    required this.title,
    required this.lastMessageDate,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        sessionId: json['sessionId']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled',
        lastMessageDate:
            DateTime.tryParse(json['lastMessageDate']?.toString() ?? '') ?? DateTime.now(),
      );
}

class ChatHistoryMessage {
  final int id;
  final String sessionId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime sentAt;

  const ChatHistoryMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.sentAt,
  });

  bool get isUser => role == 'user';

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) => ChatHistoryMessage(
        id: json['id'] as int,
        sessionId: json['sessionId']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
        content: json['content']?.toString() ?? '',
        sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

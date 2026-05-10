import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_models.dart';
import '../repository/chat_repository.dart';
import '../../auth/auth_view_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? audioUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.audioUrl,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? sessionId;
  final String? error;
  final bool ttsEnabled;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.sessionId,
    this.error,
    this.ttsEnabled = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? sessionId,
    String? error,
    bool? ttsEnabled,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      error: error ?? this.error,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    client: ref.watch(dioClientProvider),
  );
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.read(chatRepositoryProvider));
});

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository repository;

  ChatNotifier(this.repository) : super(ChatState(
    messages: const [],
    isLoading: false,
    ttsEnabled: false,
  ));

  void setSessionId(String id) {
    if (id.isNotEmpty) {
      state = state.copyWith(sessionId: id);
    }
  }

  void toggleTts() {
    state = state.copyWith(ttsEnabled: !state.ttsEnabled);
  }

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    final currentSessionId = state.sessionId;
    
    if (currentSessionId == null || currentSessionId.isEmpty) {
      state = state.copyWith(error: "لم يتم العثور على جلسة صالحة. برجاء رفع الملف أولاً.");
      return;
    }

    final userMsg = ChatMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await repository.sendMessage(
        question: question,
        sessionId: currentSessionId,
        tts: state.ttsEnabled,
      );

      final aiMsg = ChatMessage(
        text: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
        audioUrl: response.audioUrl,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        sessionId: response.sessionId.isNotEmpty ? response.sessionId : currentSessionId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "حدث خطأ أثناء إرسال الرسالة.",
      );
    }
  }

  void clearChat() {
    state = ChatState(
      sessionId: state.sessionId, 
      ttsEnabled: state.ttsEnabled,
      messages: const [],
      isLoading: false,
    );
  }
}
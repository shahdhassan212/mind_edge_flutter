// features/analysis/providers/chat_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_models.dart';
import '../repository/chat_repository.dart';
import '../../auth/auth_view_model.dart';

// ── Chat message (UI model) ───────────────────────────────────
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

  // Convert from history API model
  factory ChatMessage.fromHistory(ChatHistoryMessage h) => ChatMessage(
        text: h.content,
        isUser: h.isUser,
        timestamp: h.sentAt,
      );
}

// ── Chat state ────────────────────────────────────────────────
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? sessionId;
  final String? filename;
  final String? error;
  final bool ttsEnabled;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.sessionId,
    this.filename,
    this.error,
    this.ttsEnabled = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingHistory,
    String? sessionId,
    String? filename,
    String? error,
    bool? ttsEnabled,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
        sessionId: sessionId ?? this.sessionId,
        filename: filename ?? this.filename,
        error: error ?? this.error,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      );
}

// ── Repository provider ───────────────────────────────────────
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(client: ref.watch(dioClientProvider));
});

// ── Chat notifier ─────────────────────────────────────────────
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repo;

  ChatNotifier(this._repo) : super(ChatState());

  // Called from AIChatScreen initState
  void init({required String filename, String? sessionId}) {
    state = state.copyWith(
      filename: filename,
      sessionId: sessionId,
    );
    // Load history if we have a sessionId
    if (sessionId != null && sessionId.isNotEmpty) {
      loadHistory(sessionId);
    }
  }

  // Keep for backward compat
  void setSessionId(String id) {
    if (id.isNotEmpty) state = state.copyWith(sessionId: id);
  }

  void toggleTts() => state = state.copyWith(ttsEnabled: !state.ttsEnabled);

  // ── Load history ──────────────────────────────────────────
  Future<void> loadHistory(String sessionId) async {
    state = state.copyWith(isLoadingHistory: true, error: null);
    try {
      final history = await _repo.fetchHistory(sessionId);
      final messages = history.map(ChatMessage.fromHistory).toList();
      state = state.copyWith(
        messages: messages,
        isLoadingHistory: false,
      );
    } catch (_) {
      // Silent fail — just start with empty chat
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    final sessionId = state.sessionId;
    final filename = state.filename;

    if (filename == null || filename.isEmpty) {
      state = state.copyWith(error: 'No file associated with this chat.');
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
      final response = await _repo.sendMessage(
        question: question,
        filename: filename,
        sessionId: sessionId,
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
        sessionId: response.sessionId.isNotEmpty ? response.sessionId : sessionId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send message — please try again.',
      );
    }
  }

  void clearChat() => state = ChatState(
        sessionId: state.sessionId,
        filename: state.filename,
        ttsEnabled: state.ttsEnabled,
        messages: const [],
        isLoading: false,
        isLoadingHistory: false,
      );
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.read(chatRepositoryProvider)),
);

// ── My chats provider ─────────────────────────────────────────
final myChatsProvider = FutureProvider.autoDispose<List<ChatSession>>((ref) {
  return ref.read(chatRepositoryProvider).fetchMyChats();
});

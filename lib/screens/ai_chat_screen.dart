import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/providers/chat_providers.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const pageBg = Color(0xFFF4EDE0);
  static const cardBg = Color(0xFFFEFCF7);
  static const textDark = Color(0xFF2A1A0E);
  static const textBody = Color(0xFF3A2410);
  static const textMuted = Color(0xFF9E8A72);
  static const textHint = Color(0xFFB8A88A);
  static const goldDark = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  static const border = Color(0xFFE8D9C0);
  static const borderDash = Color(0xFFE0C898);
  static const bubbleUser = Color(0xFF2A1A0E);
  static const bubbleAI = Color(0xFFFEFCF7);
  static const inputBg = Color(0xFFF4EDE0);
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AIChatScreen extends ConsumerStatefulWidget {
  final String fileName;
  final String? sessionId;

  const AIChatScreen({super.key, required this.fileName, this.sessionId});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).setSessionId(widget.sessionId!);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Send message ─────────────────────────────────────────
  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(t);
    _ctrl.clear();
    _scrollDown();
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 150), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen(chatProvider, (prev, next) {
      final prevLen = prev?.messages.length ?? 0;
      final nextLen = next.messages.length;
      if (prevLen != nextLen) {
        _scrollDown();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EDD8), Color(0xFFEDD9B8), Color(0xFFE8D0A8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: _buildMessages(chatState)),
              if (chatState.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(chatState.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              _buildInput(chatState.isLoading, chatState.ttsEnabled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _C.cardBg,
        border: Border(bottom: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
            color: _C.textDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.cardBg.withOpacity(0.85),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: _C.textDark),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 16, color: _C.goldLight)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ask AI',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.textDark)),
                Text(widget.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'DM Sans', fontSize: 10.5, color: _C.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _C.textMuted, size: 20),
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(ChatState state) {
    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          'مرحباً! اسألني أي سؤال عن "${widget.fileName}" 🧪',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'DM Sans', color: _C.textMuted),
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (state.isLoading && i == state.messages.length) return const _TypingBubble();
        return _ChatBubble(msg: state.messages[i], displayName: widget.fileName);
      },
    );
  }

  Widget _buildInput(bool isLoading, bool ttsEnabled) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          // زر تبديل الصوت (TTS)
          GestureDetector(
            onTap: () => ref.read(chatProvider.notifier).toggleTts(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ttsEnabled ? _C.goldDark : _C.inputBg,
                shape: BoxShape.circle,
                border: Border.all(color: _C.border),
              ),
              child: Icon(
                ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 20,
                color: ttsEnabled ? Colors.white : _C.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _C.inputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: _ctrl,
                enabled: !isLoading,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textDark),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask about this document...',
                  hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textHint),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isLoading ? null : _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isLoading ? _C.textMuted : _C.bubbleUser,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, size: 17, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final String displayName;
  const _ChatBubble({required this.msg, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 7),
              decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
              child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser ? _C.bubbleUser : _C.bubbleAI,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    border: msg.isUser ? null : Border.all(color: _C.border),
                    boxShadow: [
                      BoxShadow(
                          color: _C.textDark.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: msg.isUser ? Colors.white : _C.textDark,
                      height: 1.55,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                // أيقونة الصوت إذا كان الرابط موجوداً
                if (!msg.isUser && msg.audioUrl != null && msg.audioUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/audio_screen',
                          arguments: {
                            'audioUrl': msg.audioUrl,
                            'summary': msg.text,
                            'displayName': displayName,
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _C.goldLight.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.headphones_rounded, size: 16, color: _C.goldDark),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 7),
            decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: _C.bubbleAI,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _C.border),
            ),
            child: const Text(
              'typing...',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: _C.textMuted,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

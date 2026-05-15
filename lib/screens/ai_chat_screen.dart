// screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/providers/chat_providers.dart';
import '../theme/design_tokens.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final String fileName;
  final String? sessionId;
  final String? initialMessage;
  const AIChatScreen({
    super.key,
    required this.fileName,
    this.sessionId,
    this.initialMessage,
  });

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).init(
            filename: widget.fileName,
            sessionId: widget.sessionId,
          );
      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            ref.read(chatProvider.notifier).sendMessage(widget.initialMessage!);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

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
    final state = ref.watch(chatProvider);

    ref.listen(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length) _scrollDown();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8),
              Color(0xFFEDD9B8),
              Color(0xFFE8D0A8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _ChatTopBar(
              fileName: widget.fileName,
              onBack: () => Navigator.pop(context),
              onClear: () => ref.read(chatProvider.notifier).clearChat(),
            ),
            Expanded(
                child: _MessageList(
              state: state,
              scroll: _scroll,
              fileName: widget.fileName,
            )),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Text(state.error!,
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: Colors.red)),
              ),
            _ChatInput(
              ctrl: _ctrl,
              isLoading: state.isLoading,
              ttsEnabled: state.ttsEnabled,
              onSend: _send,
              onToggleTts: () => ref.read(chatProvider.notifier).toggleTts(),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Top bar ───────────────────────────────────────────────────
class _ChatTopBar extends StatelessWidget {
  final String fileName;
  final VoidCallback onBack;
  final VoidCallback onClear;
  const _ChatTopBar({
    required this.fileName,
    required this.onBack,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.aiCardBg,
          border: Border(bottom: BorderSide(color: AppColors.aiBorder)),
          boxShadow: [
            BoxShadow(
                color: AppColors.aiTextDark.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.aiCardBg.withOpacity(0.85),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.aiBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 14, color: AppColors.aiTextDark),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.aiTextDark, shape: BoxShape.circle),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.aiGoldLight),
            ),
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
                        color: AppColors.aiTextDark)),
                Text(fileName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'DM Sans', fontSize: 10.5, color: AppColors.aiTextMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.aiTextMuted, size: 20),
            onPressed: onClear,
          ),
        ]),
      );
}

// ─── Message list ──────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  final ChatState state;
  final ScrollController scroll;
  final String fileName;
  const _MessageList({
    required this.state,
    required this.scroll,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          'مرحباً! اسألني أي سؤال عن "$fileName" 🧪',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'DM Sans', color: AppColors.aiTextMuted),
        ),
      );
    }
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (state.isLoading && i == state.messages.length) {
          return const _TypingBubble();
        }
        return _ChatBubble(msg: state.messages[i], displayName: fileName);
      },
    );
  }
}

// ─── Chat input bar ────────────────────────────────────────────
class _ChatInput extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isLoading;
  final bool ttsEnabled;
  final VoidCallback onSend;
  final VoidCallback onToggleTts;
  const _ChatInput({
    required this.ctrl,
    required this.isLoading,
    required this.ttsEnabled,
    required this.onSend,
    required this.onToggleTts,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.aiCardBg,
          border: Border(top: BorderSide(color: AppColors.aiBorder)),
        ),
        child: Row(children: [
          // TTS toggle
          GestureDetector(
            onTap: onToggleTts,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ttsEnabled ? AppColors.aiGoldDark : AppColors.chatInputBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.aiBorder),
              ),
              child: Icon(
                ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 20,
                color: ttsEnabled ? Colors.white : AppColors.aiTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.chatInputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.aiBorder),
              ),
              child: TextField(
                controller: ctrl,
                enabled: !isLoading,
                style: const TextStyle(
                    fontFamily: 'DM Sans', fontSize: 13, color: AppColors.aiTextDark),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask about this document...',
                  hintStyle:
                      TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.aiTextHint),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isLoading ? AppColors.aiTextMuted : AppColors.chatBubbleUser,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, size: 17, color: Colors.white),
            ),
          ),
        ]),
      );
}

// ─── Chat bubble ───────────────────────────────────────────────
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
              decoration:
                  const BoxDecoration(color: AppColors.chatBubbleUser, shape: BoxShape.circle),
              child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.aiGoldLight),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser ? AppColors.chatBubbleUser : AppColors.chatBubbleAI,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    border: msg.isUser ? null : Border.all(color: AppColors.aiBorder),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.aiTextDark.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: msg.isUser
                      ? Text(
                          msg.text,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: Colors.white,
                            height: 1.55,
                            fontWeight: FontWeight.w300,
                          ),
                        )
                      : MarkdownBody(
                          data: msg.text,
                          shrinkWrap: true,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.aiTextDark,
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                            ),
                            strong: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.aiTextDark,
                            ),
                            em: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.aiTextBody,
                            ),
                            h1: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.aiTextDark,
                            ),
                            h2: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.aiTextDark,
                            ),
                            h3: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.aiTextDark,
                            ),
                            listBullet: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              color: AppColors.aiGoldDark,
                            ),
                            code: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 12,
                              color: AppColors.aiGoldDark,
                              backgroundColor: AppColors.aiFormulaTagBg,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: AppColors.aiFormulaCardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.aiBorder),
                            ),
                            blockSpacing: 6,
                            listIndent: 18,
                            pPadding: const EdgeInsets.only(bottom: 4),
                          ),
                        ),
                ),
                if (!msg.isUser && msg.audioUrl != null && msg.audioUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/audio_screen',
                        arguments: {
                          'audioUrl': msg.audioUrl,
                          'summary': msg.text,
                          'displayName': displayName,
                        },
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.aiGoldLight.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.headphones_rounded,
                            size: 16, color: AppColors.aiGoldDark),
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

// ─── Typing indicator ──────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 7),
            decoration:
                const BoxDecoration(color: AppColors.chatBubbleUser, shape: BoxShape.circle),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.aiGoldLight),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.chatBubbleAI,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.aiBorder),
            ),
            child: const Text('typing...',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: AppColors.aiTextMuted,
                    fontStyle: FontStyle.italic)),
          ),
        ]),
      );
}

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS (same palette as AIAnalysisScreen)
// ─────────────────────────────────────────────────────────────
class _C {
  static const pageBg    = Color(0xFFF4EDE0);
  static const cardBg    = Color(0xFFFEFCF7);
  static const textDark  = Color(0xFF2A1A0E);
  static const textBody  = Color(0xFF3A2410);
  static const textMuted = Color(0xFF9E8A72);
  static const textHint  = Color(0xFFB8A88A);
  static const goldDark  = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  static const border    = Color(0xFFE8D9C0);
  static const borderDash= Color(0xFFE0C898);
  static const bubbleUser= Color(0xFF2A1A0E);
  static const bubbleAI  = Color(0xFFFEFCF7);
  static const inputBg   = Color(0xFFF4EDE0);
}

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  const _Msg({required this.text, required this.isUser});
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AIChatScreen extends StatefulWidget {
  /// Document name received from AIAnalysisScreen.
  /// Will also be sent to the chat endpoint as `document_name`.
  final String fileName;

  const AIChatScreen({super.key, required this.fileName});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<_Msg> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _aiTyping = false;

  // ── Placeholder replies — replace with real endpoint call ──
  static const _replies = [
    'على طول! بحلل الملف ده دلوقتي…',
    'سؤال كويس، خليني أشوف…',
    'بناءً على الملف، الإجابة هي…',
    'استنى ثانية بدور في المحتوى…',
    'لقيت المعلومة دي في الملف، تفضل…',
  ];
  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    // Opening greeting
    _msgs.add(
      _Msg(
        text: 'مرحباً! اسألني أي سؤال عن "${widget.fileName}" 🧪',
        isUser: false,
      ),
    );
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

    setState(() {
      _msgs.add(_Msg(text: t, isUser: true));
      _ctrl.clear();
      _aiTyping = true;
    });
    _scrollDown();

    // TODO: replace this delay with a real API call.
    // Send { "document_name": widget.fileName, "message": t } to your endpoint.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _aiTyping = false;
        _msgs.add(_Msg(
          text: _replies[_replyIdx % _replies.length],
          isUser: false,
        ));
        _replyIdx++;
      });
      _scrollDown();
    });
  }

  void _scrollDown() => Future.delayed(const Duration(milliseconds: 80), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      });

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
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
              Expanded(child: _buildMessages()),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────
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
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.cardBg.withOpacity(0.85),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: _C.textDark.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: _C.textDark,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // AI avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _C.textDark,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: _C.goldLight,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask AI',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
                Text(
                  widget.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Messages list ────────────────────────────────────────
  Widget _buildMessages() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      itemCount: _msgs.length + (_aiTyping ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (_aiTyping && i == _msgs.length) return const _TypingBubble();
        return _ChatBubble(msg: _msgs[i]);
      },
    );
  }

  // ── Input bar ────────────────────────────────────────────
  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        border: Border(top: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
            color: _C.textDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
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
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: _C.textDark,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask about this document...',
                  hintStyle: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: _C.textHint,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _C.bubbleUser,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 7),
              decoration: const BoxDecoration(
                color: _C.textDark,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: _C.goldLight,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? _C.bubbleUser : _C.bubbleAI,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                border:
                    msg.isUser ? null : Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: _C.textDark.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
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
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TYPING BUBBLE
// ─────────────────────────────────────────────────────────────
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
            decoration: const BoxDecoration(
              color: _C.textDark,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 13,
                color: _C.goldLight,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
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
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
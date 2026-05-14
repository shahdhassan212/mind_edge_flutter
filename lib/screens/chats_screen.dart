// screens/chats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/model/chat_models.dart';
import '../features/analysis/providers/chat_providers.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const bg1 = Color(0xFFF7EDD8);
  static const bg2 = Color(0xFFEDD9B8);
  static const bg3 = Color(0xFFE8D0A8);
  static const cardBg = Color(0xFFFEFCF7);
  static const textDark = Color(0xFF2A1A0E);
  static const textMuted = Color(0xFF9E8A72);
  static const gold = Color(0xFFC9943A);
  static const border = Color(0xFFE8D9C0);
  static const chipBg = Color(0xFFF0E8D8);
  static const chipBdr = Color(0xFFDDD0B8);
  static const errBg = Color(0xFFFCEBEB);
  static const errClr = Color(0xFFA32D2D);
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);

    return Scaffold(
      backgroundColor: _C.bg1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.bg1, _C.bg2, _C.bg3],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                _IcoBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text('My Chats',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                        )),
                  ),
                ),
                // Refresh button
                _IcoBtn(
                  icon: Icons.refresh_rounded,
                  onTap: () => ref.invalidate(myChatsProvider),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // ── Content
            Expanded(
              child: chatsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _C.gold, strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration:
                            BoxDecoration(color: _C.errBg, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.wifi_off_rounded, size: 26, color: _C.errClr),
                      ),
                      const SizedBox(height: 14),
                      const Text('Could not load chats',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _C.textDark)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => ref.invalidate(myChatsProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                          decoration: BoxDecoration(
                              color: _C.textDark, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Retry',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                ),
                data: (sessions) => sessions.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        color: _C.gold,
                        backgroundColor: _C.cardBg,
                        onRefresh: () async => ref.invalidate(myChatsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return _ChatCard(
                              session: session,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/ai-chat',
                                arguments: {
                                  'fileName': '',
                                  'sessionId': session.sessionId,
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CHAT CARD
// ─────────────────────────────────────────────────────────────
class _ChatCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const _ChatCard({required this.session, required this.onTap});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _C.cardBg,
            border: Border.all(color: _C.border, width: 1.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _C.textDark.withValues(alpha: 0.05),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _C.gold.withValues(alpha: 0.10),
                border: Border.all(color: _C.gold.withValues(alpha: 0.20)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: _C.gold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _C.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(session.lastMessageDate),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: _C.textMuted),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.chipBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.chipBdr),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 28, color: _C.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'No chats yet',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your AI chat sessions will appear here',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: _C.textMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// MICRO WIDGETS
// ─────────────────────────────────────────────────────────────
class _IcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IcoBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _C.cardBg.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: _C.textDark.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: _C.textDark),
        ),
      );
}

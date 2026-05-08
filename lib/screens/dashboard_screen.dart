// ============================================================
// Page 11 — Dashboard (Study Plan Dashboard)
// ============================================================
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';
import '../features/auth/auth_providers.dart';

// ── Study progress state (synced with active plan data) ───────
class StudyProgress {
  final String planTitle;
  final String planSubtitle;
  final double completionPct;
  final String completionLabel;
  final int daysLeft;

  const StudyProgress({
    required this.planTitle,
    required this.planSubtitle,
    required this.completionPct,
    required this.completionLabel,
    required this.daysLeft,
  });
}

final studyProgressProvider = StateProvider<StudyProgress>((_) => const StudyProgress(
      planTitle: 'Organic Chemistry\nFinal Prep',
      planSubtitle: '4-week intensive · 2h/day · Intermediate',
      completionPct: 0.68,
      completionLabel: '68% Complete',
      daysLeft: 9,
    ));

// ── Color constants matching the photo ───────────────────────
// Photo analysis:
//   Background:     warm cream  #F5EDD8  (top) → #EDD9B8 (bottom)
//   Hero card:      very dark espresso brown  #2A1A0E
//   Card circle:    muted olive-gold  #7A6035 (semi-transparent)
//   Badge bg:       dark brown pill  #3D2510
//   Stat tiles:     near-white  #FEFCF7
//   Progress bar:   gold  #C9943A → #E8B84B
//   Name highlight: warm amber  #C08B3A
//   Bottom nav:     white/translucent
//   Text dark:      #2A1A0E
//   Text muted:     #9E8A72

class _C {
  static const bgTop = Color(0xFFF7EDD8);
  static const bgBottom = Color(0xFFEDD9B8);
  static const heroCard = Color(0xFF2A1A0E); // dark espresso
  static const heroCircle = Color(0x667A6035); // muted gold semi-transparent
  static const badgeBg = Color(0xFF3D2510);
  static const badgeBorder = Color(0xFF5A3A18);
  static const goldDark = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  static const nameAmber = Color(0xFFC08B3A);
  static const textDark = Color(0xFF2A1A0E);
  static const textMuted = Color(0xFF9E8A72);
  static const statTile = Color(0xFFFEFCF7);
  static const statBorder = Color(0xFFE8D9C0);
  static const navBg = Color(0xFFFEFCF7);
  static const navBorder = Color(0xFFE0CDB0);
  static const priorityHigh = Color(0xFFC05A32);
  static const priorityMed = Color(0xFF8A6A1A);
  static const priorityLow = Color(0xFF9E8A72);
  static const taskCard = Color(0xFFFEFCF7);
  static const taskBorder = Color(0xFFE8D9C0);
  static const resumeBtn = Color(0x33FFFFFF); // white 20%
  static const resumeBorder = Color(0x55FFFFFF);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final firstName = userAsync.when(
      data: (u) => u?.firstName ?? 'there',
      loading: () => '…',
      error: (_, __) => 'there',
    );
    final progress = ref.watch(studyProgressProvider);

    return Scaffold(
      backgroundColor: _C.bgTop,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Warm cream gradient matching the photo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8), // top — light cream
              Color(0xFFF0E0C0), // mid — warm sand
              Color(0xFFE8D0A8), // bottom — deeper tan
            ],
          ),
        ),
        child: Stack(children: [
          // Subtle top-right glow orb
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _C.goldLight.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  radius: 0.65,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(children: [
              // ── Greeting header ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Monday, Oct 24 · Week 2 of 4',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: _C.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text.rich(TextSpan(
                        text: 'Good morning, ',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(
                            text: '$firstName ',
                            style: TextStyle(color: _C.nameAmber),
                          ),
                          const TextSpan(text: '👋'),
                        ],
                      )),
                    ]),
                    const Spacer(),
                    _BellBtn(),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(children: [
                    // ── Hero card — Active Plan ───────────────
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/study-plan'),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            // Dark espresso brown — matches photo exactly
                            color: _C.heroCard,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: _C.heroCard.withValues(alpha: 0.50),
                                blurRadius: 40,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Stack(clipBehavior: Clip.hardEdge, children: [
                            // Decorative circle (top-right, muted gold)
                            Positioned(
                              top: -35,
                              right: -35,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _C.heroCircle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // "Active Plan" badge
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _C.badgeBg,
                                      border: Border.all(color: _C.badgeBorder),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('▶',
                                            style:
                                                TextStyle(fontSize: 9, color: Color(0xFFD4A84B))),
                                        SizedBox(width: 5),
                                        Text('Active Plan',
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD4A84B),
                                              letterSpacing: 0.3,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Plan title
                                  Text(
                                    progress.planTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                      height: 1.22,
                                    ),
                                  ),
                                  const SizedBox(height: 5),

                                  // Plan subtitle
                                  Text(
                                    progress.planSubtitle,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.50),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Progress bar
                                  Stack(children: [
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.20),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: progress.completionPct,
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [_C.goldDark, _C.goldLight],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 8),

                                  // Completion label + Resume button
                                  Row(children: [
                                    Text(
                                      '${progress.completionLabel} · ${progress.daysLeft} days left',
                                      style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: _C.goldLight,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _C.resumeBtn,
                                        border: Border.all(color: _C.resumeBorder, width: 1.5),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('▶',
                                              style: TextStyle(fontSize: 9, color: Colors.white)),
                                          SizedBox(width: 5),
                                          Text('Resume',
                                              style: TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    // ── Stats row ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(children: [
                        _StatTile(value: '12', label: 'Sessions'),
                        const SizedBox(width: 8),
                        _StatTile(value: '24h', label: 'Studied', valueFontSize: 16),
                        const SizedBox(width: 8),
                        _StatTile(value: '🔥7', label: 'Streak', valueColor: _C.textDark),
                      ]),
                    ),

                    // ── Today's Tasks header ──────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Row(children: [
                        Text(
                          "Today's Tasks",
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.textDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _C.nameAmber,
                          ),
                        ),
                      ]),
                    ),

                    // ── Task list ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(children: [
                        _TaskCard(
                          done: true,
                          name: 'Review Nucleophilic Substitution',
                          meta: '30 min · Completed 8:14 AM',
                          priority: 'Med',
                          priorityType: 1,
                        ),
                        const SizedBox(height: 7),
                        _TaskCard(
                          done: false,
                          name: 'Practice Problems — Ch.9 Reactions',
                          meta: '45 min · Est. 3:00 PM',
                          priority: 'High',
                          priorityType: 2,
                        ),
                        const SizedBox(height: 7),
                        _TaskCard(
                          done: false,
                          name: 'Audio: Carbonyl Chemistry Overview',
                          meta: '20 min · AI audio explanation',
                          priority: 'Low',
                          priorityType: 0,
                        ),
                      ]),
                    ),

                    // ── AI recommendation strip ───────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: _AIStrip(
                        icon: '✦',
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'AI Recommendation: ',
                            style: TextStyle(fontWeight: FontWeight.w600, color: _C.textDark),
                          ),
                          const TextSpan(
                            text:
                                'Schedule extra time on Electrophilic Addition before Friday\'s review.',
                          ),
                        ]),
                      ),
                    ),

                    // ── Take Quiz button ─────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: CustomPrimaryButton(
                        text: 'Take Quiz  ✦',
                        onTap: () => Navigator.pushNamed(context, '/quiz'),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ]),
                ),
              ),

              // ── Bottom nav ────────────────────────────────
              _BottomNav(
                active: 0,
                onTap: (i) {
                  if (i == 0) Navigator.pushNamed(context, '/study-plan'); // Plans
                  if (i == 1) Navigator.pushNamed(context, '/library'); // Library
                  if (i == 2) Navigator.pushNamed(context, '/scan'); // + FAB
                  if (i == 3) Navigator.pushNamed(context, '/ai-analysis'); // 🤖 AI
                  if (i == 4) Navigator.pushNamed(context, '/settings'); // Settings
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _BellBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.statBorder),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: const Center(child: Text('🔔', style: TextStyle(fontSize: 17))),
      );
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final double valueFontSize;
  final Color? valueColor;
  const _StatTile(
      {required this.value, required this.label, this.valueFontSize = 20, this.valueColor});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: _C.statTile,
            border: Border.all(color: _C.statBorder, width: 1.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: valueFontSize,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _C.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9,
                color: _C.textMuted,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      );
}

class _TaskCard extends StatelessWidget {
  final bool done;
  final String name;
  final String meta;
  final String priority;
  final int priorityType; // 0=low 1=med 2=high

  const _TaskCard({
    required this.done,
    required this.name,
    required this.meta,
    required this.priority,
    required this.priorityType,
  });

  Color get _priColor {
    switch (priorityType) {
      case 2:
        return _C.priorityHigh;
      case 1:
        return _C.priorityMed;
      default:
        return _C.priorityLow;
    }
  }

  Color get _priBg {
    switch (priorityType) {
      case 2:
        return _C.priorityHigh.withValues(alpha: 0.15);
      case 1:
        return _C.goldDark.withValues(alpha: 0.18);
      default:
        return _C.textMuted.withValues(alpha: 0.12);
    }
  }

  Color get _priBorder {
    switch (priorityType) {
      case 2:
        return _C.priorityHigh.withValues(alpha: 0.40);
      case 1:
        return _C.goldDark.withValues(alpha: 0.40);
      default:
        return _C.textMuted.withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: done ? 0.60 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _C.taskCard,
            border: Border.all(color: _C.taskBorder, width: 1.2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            // Checkbox circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: done
                    ? const LinearGradient(
                        colors: [_C.textDark, _C.goldDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: done
                    ? null
                    : Border.all(color: _C.textMuted.withValues(alpha: 0.50), width: 1.8),
                color: done ? null : Colors.white,
              ),
              child: done
                  ? const Center(
                      child: Text('✓',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              height: 1,
                              fontWeight: FontWeight.w700)))
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: done ? _C.textMuted : _C.textDark,
                    height: 1.3,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: _C.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _priBg,
                border: Border.all(color: _priBorder, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: _priColor,
                ),
              ),
            ),
          ]),
        ),
      );
}

class _AIStrip extends StatelessWidget {
  final String icon;
  final TextSpan text;
  const _AIStrip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.70),
          border: Border(
            top: BorderSide(color: _C.goldDark.withValues(alpha: 0.25)),
            right: BorderSide(color: _C.goldDark.withValues(alpha: 0.25)),
            bottom: BorderSide(color: _C.goldDark.withValues(alpha: 0.25)),
            left: BorderSide(color: _C.textDark.withValues(alpha: 0.75), width: 3),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: TextStyle(fontSize: 15, color: _C.goldDark)),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: _C.textDark.withValues(alpha: 0.75),
                fontWeight: FontWeight.w300,
                height: 1.55,
              ),
            ),
          ),
        ]),
      );
}

class _BottomNav extends StatelessWidget {
  final int active;
  final void Function(int) onTap;
  const _BottomNav({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        // Clean white bottom nav matching the photo
        color: _C.navBg,
        border: Border(top: BorderSide(color: _C.navBorder, width: 1)),
        boxShadow: [
          BoxShadow(
              color: _C.textDark.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NavItem(
          emoji: '🏠',
          label: 'Plans',
          on: active == 0,
          // ✅ Plans → /study_plan
          onTap: () => onTap(0),
        ),
        _NavItem(
          emoji: '📚',
          label: 'Library',
          on: active == 1,
          onTap: () => onTap(1),
        ),


        
        // FAB ＋ button
        GestureDetector(
          onTap: () => onTap(2),
          child: Container(
            width: 46,
            height: 46,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
      
              gradient: const LinearGradient(
                colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  // التعديل: نفس قيم الظل لضمان نفس تأثير الـ Depth
                  color: _C.textDark.withValues(alpha: 0.32),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Center(
              child: Text(
                '＋',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white, // تغيير اللون للأبيض ليناسب التدرج الجديد
                  fontWeight: FontWeight.w600, // زيادة الوزن ليتماشى مع الـ Style
                ),
              ),
            ),
          ),
        ),
        _NavItem(
          emoji: '🤖',
          label: 'AI',
          on: active == 3,
          onTap: () => onTap(3),
        ),
        _NavItem(
          emoji: '⚙',
          label: 'Settings',
          on: active == 4,
          onTap: () => onTap(4),
        ),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _NavItem({required this.emoji, required this.label, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: on ? _C.textDark : _C.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ]),
      );
}

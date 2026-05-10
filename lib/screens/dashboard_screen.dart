// screens/dashboard_screen.dart
// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dashboard_widgets.dart';
import '../features/auth/auth_providers.dart';

// ── Study progress state (mock until study-plan endpoint is ready) ─
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

final studyProgressProvider = StateProvider<StudyProgress>(
  (_) => const StudyProgress(
    planTitle: 'Organic Chemistry\nFinal Prep',
    planSubtitle: '4-week intensive · 2h/day · Intermediate',
    completionPct: 0.68,
    completionLabel: '68% Complete',
    daysLeft: 9,
  ),
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(currentUserProvider).when(
          data: (u) => u?.firstName ?? 'there',
          loading: () => '…',
          error: (_, __) => 'there',
        );
    final progress = ref.watch(studyProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.dashBgTop,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8),
              Color(0xFFF0E0C0),
              Color(0xFFE8D0A8),
            ],
          ),
        ),
        child: Stack(children: [
          // Subtle top-right glow
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
                    AppColors.dashGoldLight.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  radius: 0.65,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(children: [
              // ── Greeting header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monday, Oct 24 · Week 2 of 4',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.dashTextMuted,
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
                            color: AppColors.dashTextDark,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            TextSpan(
                                text: '$firstName ',
                                style: TextStyle(color: AppColors.dashNameAmber)),
                            const TextSpan(text: '👋'),
                          ],
                        )),
                      ],
                    ),
                    const Spacer(),
                    const DashBellBtn(),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(children: [
                    // ── Hero card — Active Plan
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/study-plan'),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.dashHeroCard,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dashHeroCard.withValues(alpha: 0.50),
                                blurRadius: 40,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // Decorative circle
                              Positioned(
                                top: -35,
                                right: -35,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: AppColors.dashHeroCircle),
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
                                        color: AppColors.dashBadgeBg,
                                        border: Border.all(color: AppColors.dashBadgeBorder),
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
                                            gradient: const LinearGradient(colors: [
                                              AppColors.dashGoldDark,
                                              AppColors.dashGoldLight,
                                            ]),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 8),

                                    // Label + Resume button
                                    Row(children: [
                                      Text(
                                        '${progress.completionLabel} · ${progress.daysLeft} days left',
                                        style: const TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.dashGoldLight,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.dashResumeBtn,
                                          border: Border.all(
                                              color: AppColors.dashResumeBorder, width: 1.5),
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
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Stats row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(children: [
                        const DashStatTile(value: '12', label: 'Sessions'),
                        const SizedBox(width: 8),
                        const DashStatTile(value: '24h', label: 'Studied', valueFontSize: 16),
                        const SizedBox(width: 8),
                        DashStatTile(
                            value: '🔥7', label: 'Streak', valueColor: AppColors.dashTextDark),
                      ]),
                    ),

                    // ── Today's Tasks header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                      child: Row(children: [
                        Text(
                          "Today's Tasks",
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dashTextDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dashNameAmber,
                          ),
                        ),
                      ]),
                    ),

                    // ── Task list (mock — replace when endpoint ready)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Column(children: const [
                        DashTaskCard(
                          done: true,
                          name: 'Review Nucleophilic Substitution',
                          meta: '30 min · Completed 8:14 AM',
                        ),
                        SizedBox(height: 7),
                        DashTaskCard(
                          done: false,
                          name: 'Practice Problems — Ch.9 Reactions',
                          meta: '45 min · Est. 3:00 PM',
                        ),
                        SizedBox(height: 7),
                        DashTaskCard(
                          done: false,
                          name: 'Audio: Carbonyl Chemistry Overview',
                          meta: '20 min · AI audio explanation',
                        ),
                      ]),
                    ),

                    // ── AI recommendation strip
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: DashAIStrip(
                        text: TextSpan(children: [
                          TextSpan(
                            text: 'AI Recommendation: ',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: AppColors.dashTextDark),
                          ),
                          const TextSpan(
                            text:
                                'Schedule extra time on Electrophilic Addition before Friday\'s review.',
                          ),
                        ]),
                      ),
                    ),

                    // ── Take Quiz button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: AppButton(
                        label: 'Take Quiz  ✦',
                        onTap: () => Navigator.pushNamed(context, '/quiz'),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ]),
                ),
              ),

              // ── Bottom nav
              DashBottomNav(
                active: 0,
                onTap: (i) {
                  if (i == 0) Navigator.pushNamed(context, '/study-plan');
                  if (i == 1) Navigator.pushNamed(context, '/library');
                  if (i == 2) Navigator.pushNamed(context, '/scan');
                  if (i == 3) Navigator.pushNamed(context, '/ai-analysis');
                  if (i == 4) Navigator.pushNamed(context, '/settings');
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

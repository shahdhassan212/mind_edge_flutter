// ============================================================
// Page 19 — Quiz Results
// ============================================================
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  static const _breakdown = [
    ('Q1', 'Bond polarity and electronegativity', true),
    ('Q2', 'Orbital hybridization in alkenes', true),
    ('Q3', 'SN1 vs SN2 mechanism comparison', true),
    ('Q4', "Markovnikov's rule application", false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)])),
        child: Stack(children: [
          Positioned(
              top: -60,
              right: -60,
              child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [AppColors.gold.withOpacity(0.12), Colors.transparent],
                          radius: 0.68)))),
          SafeArea(
              child: Column(children: [
            // Nav
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: Row(children: [
                const SizedBox(width: 36),
                const Spacer(),
                const Text('Quiz Results',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                const Spacer(),
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16)),
                        boxShadow: AppShadows.sm),
                    child: const Center(
                        child: Text('↑', style: TextStyle(fontSize: 14, color: AppColors.cocoa)))),
              ]),
            ),

            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(children: [
                // Score ring
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
                  child: Column(children: [
                    SizedBox(
                        width: 96,
                        height: 96,
                        child: CustomPaint(
                            painter: _ScoreRingPainter(0.78),
                            child: const Center(
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('78%',
                                  style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.cocoaDeep)),
                              Text('Score',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans', fontSize: 9, color: AppColors.muted)),
                            ])))),
                    const SizedBox(height: 14),
                    const Text('Good work, Alex',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cocoaDeep,
                            letterSpacing: -0.025 * 22)),
                    const SizedBox(height: 3),
                    const Text('Organic Chemistry · 10 Questions',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w300)),
                  ]),
                ),

                // Stats
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Row(children: [
                    _StatTile(value: '8', label: 'Correct', color: const Color(0xFF4A6128)),
                    const SizedBox(width: 8),
                    _StatTile(value: '2', label: 'Incorrect', color: const Color(0xFF9C2A1E)),
                    const SizedBox(width: 8),
                    _StatTile(value: '4m', label: 'Time'),
                  ]),
                ),

                // Breakdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('ANSWER BREAKDOWN',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.12 * 10.5,
                            color: AppColors.muted)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: _breakdown
                            .asMap()
                            .map((i, item) {
                              final isLast = i == _breakdown.length - 1;
                              return MapEntry(
                                  i,
                                  Column(children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                      child: Row(children: [
                                        SizedBox(
                                            width: 20,
                                            child: Text(item.$1,
                                                style: const TextStyle(
                                                    fontFamily: 'DM Sans',
                                                    fontSize: 11,
                                                    color: AppColors.muted))),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Text(item.$2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontFamily: 'DM Sans',
                                                    fontSize: 12,
                                                    color: AppColors.cocoaDeep))),
                                        const SizedBox(width: 8),
                                        _ResultBadge(correct: item.$3),
                                      ]),
                                    ),
                                    if (!isLast)
                                      Divider(
                                          height: 1,
                                          color: const Color(0xFFB48C50).withOpacity(0.1)),
                                  ]));
                            })
                            .values
                            .toList(),
                      ),
                    ),
                  ]),
                ),

                // AI insight
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.52),
                        border: Border(
                            top: BorderSide(color: AppColors.gold.withOpacity(0.18)),
                            right: BorderSide(color: AppColors.gold.withOpacity(0.18)),
                            bottom: BorderSide(color: AppColors.gold.withOpacity(0.18)),
                            left: BorderSide(color: AppColors.gold.withOpacity(0.5), width: 3)),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14), bottomRight: Radius.circular(14))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('✦', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text.rich(TextSpan(
                              text: 'Focus area: ',
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: Color(0xFF6B4C3B),
                                  fontWeight: FontWeight.w600),
                              children: const [
                            TextSpan(
                                text:
                                    "Review Markovnikov's rule and Electrophilic Addition. AI audio explanation available.",
                                style: TextStyle(fontWeight: FontWeight.w300)),
                          ]))),
                    ]),
                  ),
                ),

                // CTAs
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Row(children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/quiz'),
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              border: Border.all(
                                  color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.sm),
                          child: const Text('Retry Quiz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoa))),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 4,
                        child: CustomPrimaryButton(
                          text: 'Study Weak Areas ✦',
                          onTap: () => Navigator.pushNamed(context, '/audio'),
                        )),
                  ]),
                ),
              ]),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double pct;
  const _ScoreRingPainter(this.pct);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3.5;
    final bg = Paint()
      ..color = AppColors.cocoa.withOpacity(0.1)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c, r, bg);
    final fg = Paint()
      ..shader = const LinearGradient(colors: [AppColors.cocoa, AppColors.gold])
          .createShader(Rect.fromCircle(center: c, radius: r))
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), -3.14159 / 2, 2 * 3.14159 * pct, false, fg);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final Color? color;
  const _StatTile({required this.value, required this.label, this.color});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.58),
              border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.sm),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color ?? AppColors.cocoaDeep,
                    letterSpacing: -0.03 * 20)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 9.5,
                    color: AppColors.muted,
                    letterSpacing: 0.05 * 9.5)),
          ])));
}

class _ResultBadge extends StatelessWidget {
  final bool correct;
  const _ResultBadge({required this.correct});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: correct
              ? const Color(0xFF5C7A3A).withOpacity(0.1)
              : const Color(0xFFC0392B).withOpacity(0.08),
          border: Border.all(
              color: correct
                  ? const Color(0xFF5C7A3A).withOpacity(0.2)
                  : const Color(0xFFC0392B).withOpacity(0.18)),
          borderRadius: BorderRadius.circular(100)),
      child: Text(correct ? '✓ Correct' : '✗ Wrong',
          style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: correct ? const Color(0xFF4A6128) : const Color(0xFF9C2A1E))));
}

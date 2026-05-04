// ============================================================
// Page 16 — Progress Tracking
// ============================================================
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // [prev, this] heights in px
  static const _bars = [
    [28.0, 38.0],
    [20.0, 52.0],
    [36.0, 44.0],
    [14.0, 32.0],
    [42.0, 58.0],
    [8.0, 20.0],
    [18.0, 12.0],
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
                colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDBC0)])),
        child: Stack(children: [
          Positioned(
              top: -60,
              right: -60,
              child: Container(
                  width: 240,
                  height: 240,
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
                const AppBackButton(),
                const Spacer(),
                const Text('My Progress',
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
                        child: Text('↑↓', style: TextStyle(fontSize: 13, color: AppColors.cocoa)))),
              ]),
            ),

            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(children: [
                // Streak card
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.gold.withOpacity(0.14),
                          AppColors.cocoa.withOpacity(0.06)
                        ]),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.sm),
                    child: Row(children: [
                      const Text('🔥', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('7-Day Streak',
                            style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cocoaDeep,
                                letterSpacing: -0.03 * 22,
                                height: 1)),
                        const SizedBox(height: 2),
                        const Text('Keep it up — study today to extend it',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300)),
                      ])),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                              color: AppColors.cocoa.withOpacity(0.1),
                              border: Border.all(color: AppColors.cocoa.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(100)),
                          child: const Text('View',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoa))),
                    ]),
                  ),
                ),

                // Weekly hours chart
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.58),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShadows.md),
                    child: Column(children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Weekly Hours',
                              style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cocoaDeep)),
                          const SizedBox(height: 2),
                          const Text('This week vs last week',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w300)),
                        ]),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFF5C8A40).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFF5C8A40).withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(100)),
                            child: const Text('↑ 18%',
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5C8A40)))),
                      ]),
                      const SizedBox(height: 12),
                      // Bar chart
                      SizedBox(
                        height: 64,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(_days.length, (i) {
                            final isLast = i == _days.length - 1;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: isLast ? 0 : 6),
                                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  Column(mainAxisSize: MainAxisSize.min, children: [
                                    Container(
                                        height: _bars[i][0],
                                        decoration: BoxDecoration(
                                            color: AppColors.cocoa.withOpacity(0.18),
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(4)))),
                                    const SizedBox(height: 2),
                                    Container(
                                        height: isLast ? _bars[i][1] * 0.5 : _bars[i][1],
                                        decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [AppColors.cocoa, AppColors.gold]),
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(4)),
                                            boxShadow: isLast
                                                ? []
                                                : [
                                                    BoxShadow(
                                                        color: AppColors.cocoa.withOpacity(0.25),
                                                        blurRadius: 12,
                                                        offset: const Offset(0, 4))
                                                  ]),
                                        child: isLast
                                            ? Opacity(opacity: 0.5, child: Container())
                                            : null),
                                  ]),
                                  const SizedBox(height: 3),
                                  Text(_days[i],
                                      style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 9,
                                          color: isLast ? AppColors.cocoa : AppColors.muted,
                                          fontWeight: isLast ? FontWeight.w600 : FontWeight.w400)),
                                ]),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Legend
                      Row(children: [
                        Container(
                            width: 10,
                            height: 3,
                            decoration: BoxDecoration(
                                gradient: AppGradients.progress,
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 5),
                        const Text('This week',
                            style: TextStyle(
                                fontFamily: 'DM Sans', fontSize: 9.5, color: AppColors.muted)),
                        const SizedBox(width: 16),
                        Container(
                            width: 10,
                            height: 3,
                            decoration: BoxDecoration(
                                color: AppColors.cocoa.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 5),
                        const Text('Last week',
                            style: TextStyle(
                                fontFamily: 'DM Sans', fontSize: 9.5, color: AppColors.muted)),
                      ]),
                    ]),
                  ),
                ),

                // Ring cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Row(children: [
                    Expanded(
                        child: _RingCard(
                            title: 'Tasks Done',
                            sub: 'This week',
                            pct: 0.70,
                            label: '70%',
                            detail: '14 of 20 tasks')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _RingCard(
                            title: 'Accuracy',
                            sub: 'Avg this week',
                            pct: 0.85,
                            label: '85%',
                            detail: '17 of 20 correct')),
                  ]),
                ),

                // AI feedback
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.sm),
                    child: Column(children: [
                      Row(children: [
                        Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: [AppColors.cocoaDark, AppColors.cocoa],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)),
                            child: const Center(child: Text('✦', style: TextStyle(fontSize: 13)))),
                        const SizedBox(width: 8),
                        const Text('MindEdge AI · Weekly Insight',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cocoaDeep)),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.12),
                                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(100)),
                            child: const Text('✦ AI',
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold,
                                    letterSpacing: 0.08 * 9))),
                      ]),
                      const SizedBox(height: 9),
                      Text.rich(TextSpan(
                          text: 'Strong week. ',
                          style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.5,
                              color: Color(0xFF6B4C3B),
                              fontWeight: FontWeight.w600),
                          children: const [
                            TextSpan(
                                text:
                                    'Your Friday session was most productive. Quiz accuracy on Nucleophilic Reactions dropped to ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, color: Color(0xFF6B4C3B))),
                            TextSpan(
                                text: '62%',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: AppColors.cocoaDeep)),
                            TextSpan(
                                text: ' — AI audio explanations suggested.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, color: Color(0xFF6B4C3B))),
                          ])),
                    ]),
                  ),
                ),
              ]),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _RingCard extends StatelessWidget {
  final String title, sub, label, detail;
  final double pct;
  const _RingCard(
      {required this.title,
      required this.sub,
      required this.pct,
      required this.label,
      required this.detail});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.sm),
        child: Column(children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                Text(sub,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w300)),
              ])),
          const SizedBox(height: 8),
          SizedBox(
              width: 56,
              height: 56,
              child: CustomPaint(
                  painter: _DonutPainter(pct),
                  child: Center(
                      child: Text(label,
                          style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep))))),
          const SizedBox(height: 6),
          Text(detail,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontFamily: 'DM Sans', fontSize: 10.5, color: AppColors.muted)),
        ]),
      );
}

class _DonutPainter extends CustomPainter {
  final double pct;
  const _DonutPainter(this.pct);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2.5;
    final bg = Paint()
      ..color = AppColors.cocoa.withOpacity(0.1)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c, r, bg);
    final fg = Paint()
      ..shader = const LinearGradient(colors: [AppColors.cocoa, AppColors.gold])
          .createShader(Rect.fromCircle(center: c, radius: r))
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), -3.14159 / 2, 2 * 3.14159 * pct, false, fg);
  }

  @override
  bool shouldRepaint(_DonutPainter o) => o.pct != pct;
}

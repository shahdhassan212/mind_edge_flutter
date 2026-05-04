// ============================================================
// Page 15 — Study Plan Generator
// ============================================================
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';


class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});
  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final _subjectCtrl = TextEditingController(text: 'Organic Chemistry');
  int _duration = 1; // 0=2w 1=4w 2=6w
  int _daily = 1; // 0=1h 1=2h 2=3h+
  int _diff = 0; // 0=Beginner 1=Advanced

  @override
  void dispose() {
    _subjectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF4E9D6), Color(0xFFECDAC0)])),
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
                const Text('New Study Plan',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                const Spacer(),
                const Text('Save',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cocoa)),
              ]),
            ),

            const AuthStepBar(steps: 3, filled: 1),
            const Padding(
                padding: EdgeInsets.fromLTRB(26, 5, 26, 0),
                child: Text('Step 1 of 3 — Subject & Goals',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.muted,
                        letterSpacing: 0.08 * 10))),

            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(children: [
                // Subject input
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('SUBJECT OR TOPIC',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B4C3B),
                            letterSpacing: 1.0)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.72),
                          border: Border.all(color: AppColors.cocoa, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.cocoa.withOpacity(0.08),
                                blurRadius: 0,
                                spreadRadius: 3),
                            ...AppShadows.sm
                          ]),
                      child: Row(children: [
                        Expanded(
                            child: Text(_subjectCtrl.text,
                                style: const TextStyle(
                                    fontFamily: 'Syne',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cocoaDeep,
                                    letterSpacing: -0.01 * 15))),
                        _BlinkCursor(),
                      ]),
                    ),
                  ]),
                ),

                // Options
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Column(children: [
                    _OptionRow(
                        title: 'Study Duration',
                        sub: 'How many weeks?',
                        options: const ['2w', '4w', '6w'],
                        selected: _duration,
                        onSelect: (i) => setState(() => _duration = i)),
                    const SizedBox(height: 9),
                    _OptionRow(
                        title: 'Daily Goal',
                        sub: 'Hours per day',
                        options: const ['1h', '2h', '3h+'],
                        selected: _daily,
                        onSelect: (i) => setState(() => _daily = i)),
                    const SizedBox(height: 9),
                    _OptionRow(
                        title: 'Difficulty',
                        sub: 'Current level',
                        options: const ['Beginner', 'Advanced'],
                        selected: _diff,
                        onSelect: (i) => setState(() => _diff = i)),
                  ]),
                ),

                // Upload zone
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        border: Border.all(
                            color: const Color(0xFFB48C50).withOpacity(0.3),
                            width: 1.5,
                            style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.sm),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFB48C50).withOpacity(0.3),
                              width: 1.5,
                              style: BorderStyle.none)),
                      child: _DashedBorder(
                        color: const Color(0xFFB48C50).withOpacity(0.3),
                        borderRadius: 18,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(children: [
                            Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.12),
                                    border: Border.all(color: AppColors.gold.withOpacity(0.24)),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Center(
                                    child: Text('📄', style: TextStyle(fontSize: 18)))),
                            const SizedBox(width: 14),
                            Expanded(
                                child:
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Upload Course Materials',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.cocoaDeep)),
                              const SizedBox(height: 2),
                              const Text('PDFs, notes, or scan via OCR',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 10.5,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w300)),
                            ])),
                            const Text('Add ＋',
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cocoa)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),

                // AI indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.58),
                        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.sm),
                    child: Row(children: [
                      _PulseGold(),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('AI analyzing your subject scope',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.cocoaDeep)),
                        const Text('RAG engine preparing contextual breakdown…',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w300)),
                      ]),
                    ]),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 8),
                  child: PrimaryButton(
                      label: 'Generate My Study Plan ✦',
                      gradient: AppGradients.ctaButtonFinal,
                      onTap: () => Navigator.pushNamed(context, '/dashboard')),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 20),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/progress'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.cocoa.withValues(alpha: 0.08),
                        border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.22), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'View Progress',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cocoa,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
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

class _OptionRow extends StatelessWidget {
  final String title, sub;
  final List<String> options;
  final int selected;
  final void Function(int) onSelect;
  const _OptionRow(
      {required this.title,
      required this.sub,
      required this.options,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.52),
            border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.15), width: 1.5),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.sm),
        child: Row(children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cocoaDeep)),
            Text(sub,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w300)),
          ])),
          Row(
              children: options
                  .asMap()
                  .map((i, label) => MapEntry(
                      i,
                      GestureDetector(
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: EdgeInsets.only(left: i > 0 ? 5 : 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                gradient: i == selected ? AppGradients.ctaButton : null,
                                color: i == selected ? null : AppColors.cocoa.withOpacity(0.1),
                                border: Border.all(
                                    color: i == selected
                                        ? Colors.transparent
                                        : AppColors.cocoa.withOpacity(0.18)),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: i == selected
                                    ? [
                                        BoxShadow(
                                            color: AppColors.cocoaDeep.withOpacity(0.22),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4))
                                      ]
                                    : null),
                            child: Text(label,
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: i == selected ? AppColors.white : AppColors.cocoa)),
                          ),
                        ),
                      )))
                  .values
                  .toList()),
        ]),
      );
}

// Animated dashed border (approximation using CustomPaint)
class _DashedBorder extends StatelessWidget {
  final Color color;
  final double borderRadius;
  final Widget child;
  const _DashedBorder({required this.color, required this.borderRadius, required this.child});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DashPainter(color: color, radius: borderRadius), child: child);
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashPainter({required this.color, required this.radius});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius));
    const dash = 6.0, gap = 4.0;
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    double dist = 0;
    bool draw = true;
    while (dist < metric.length) {
      final seg = draw ? dash : gap;
      if (draw) {
        final sub = metric.extractPath(dist, dist + seg);
        canvas.drawPath(sub, paint);
      }
      dist += seg;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BlinkCursor extends StatefulWidget {
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
          opacity: _c.value > 0.5 ? 1 : 0,
          child: Container(
              width: 2,
              height: 16,
              decoration:
                  BoxDecoration(color: AppColors.cocoa, borderRadius: BorderRadius.circular(1)))));
}

class _PulseGold extends StatefulWidget {
  @override
  State<_PulseGold> createState() => _PulseGoldState();
}

class _PulseGoldState extends State<_PulseGold> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
          opacity: 0.6 + _c.value * 0.4,
          child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold))));
}

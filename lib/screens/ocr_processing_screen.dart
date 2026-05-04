// ============================================================
// Page 13 — OCR Processing State
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class OcrProcessingScreen extends StatefulWidget {
  const OcrProcessingScreen({super.key});
  @override
  State<OcrProcessingScreen> createState() => _OcrProcessingScreenState();
}

class _OcrProcessingScreenState extends State<OcrProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  double _pct = 0.0;
  Timer? _timer;

  // 0=pending 1=active 2=done
  final List<int> _steps = [2, 1, 0];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    // Simulate progress
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      setState(() {
        _pct = (_pct + 0.005).clamp(0.0, 1.0);
        if (_pct >= 0.64) _timer?.cancel();
      });
    });
    // After done, navigate
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) Navigator.pushNamed(context, '/ai-result');
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

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
                stops: [0.0, 0.45, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF5EBDA), Color(0xFFECDCBF)])),
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
                const Text('Processing Document',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                const Spacer(),
                const SizedBox(width: 36),
              ]),
            ),

            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Spinning ring
                SizedBox(
                  width: 100,
                  height: 100,
                  child: AnimatedBuilder(
                    animation: _spinCtrl,
                    builder: (_, __) => CustomPaint(
                        painter: _RingPainter(_spinCtrl.value),
                        child: const Center(child: Text('✦', style: TextStyle(fontSize: 22)))),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text('Analyzing Document',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cocoaDeep,
                        letterSpacing: -0.02 * 20)),
                const SizedBox(height: 8),
                const Text(
                    'Our OCR engine is extracting text and identifying structure from your document.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w300,
                        height: 1.6)),
                const SizedBox(height: 24),

                // Steps
                Column(children: [
                  _StepRow(status: _steps[0], label: 'Document detected & captured'),
                  const SizedBox(height: 10),
                  _StepRow(status: _steps[1], label: 'Extracting text with OCR…'),
                  const SizedBox(height: 10),
                  _StepRow(status: _steps[2], label: 'AI analysis & topic extraction'),
                ]),
                const SizedBox(height: 24),

                // Progress bar
                Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Processing',
                        style:
                            TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.muted)),
                    Text('${(_pct * 100).toInt()}%',
                        style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cocoa)),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cocoa.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2)),
                    child: FractionallySizedBox(
                      widthFactor: _pct,
                      alignment: Alignment.centerLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(children: [
                          Container(
                              decoration: const BoxDecoration(gradient: AppGradients.progress)),
                          _Shimmer(),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ]),
            )),
          ])),
        ]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  const _RingPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    final bg = Paint()
      ..color = AppColors.cocoa.withOpacity(0.1)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, r, bg);
    final fg = Paint()
      ..shader = const LinearGradient(colors: [AppColors.cocoa, AppColors.gold])
          .createShader(Rect.fromCircle(center: center, radius: r))
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const sweep = 3.14159 * 1.5;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), t * 2 * 3.14159 - 3.14159 / 2, sweep,
        false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

class _StepRow extends StatelessWidget {
  final int status; // 0=pending 1=active 2=done
  final String label;
  const _StepRow({required this.status, required this.label});
  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: status == 0 ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(status == 0 ? 0.4 : 0.62),
            border: Border.all(
                color: status == 2
                    ? const Color(0xFF5C7A3A).withOpacity(0.2)
                    : status == 1
                        ? AppColors.gold.withOpacity(0.2)
                        : const Color(0xFFB48C50).withOpacity(0.1)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.sm,
          ),
          child: Row(children: [
            _StepIcon(status: status),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: status == 2 ? const Color(0xFF4A6128) : AppColors.cocoaDeep)),
          ]),
        ),
      );
}

class _StepIcon extends StatelessWidget {
  final int status;
  const _StepIcon({required this.status});
  @override
  Widget build(BuildContext context) {
    if (status == 2) {
      return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFF3D5226), Color(0xFF5C7A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: const Center(
              child: Text('✓',
                  style:
                      TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700))));
    }
    if (status == 1) {
      return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.ctaButton),
          child: Center(child: _PulseCircle()));
    }
    return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cocoa.withOpacity(0.2), width: 2)));
  }
}

class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
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
          opacity: 0.6 + _c.value * 0.4,
          child: Container(
              width: 8,
              height: 8,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: AppColors.goldLight))));
}

class _Shimmer extends StatefulWidget {
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => FractionalTranslation(
          translation: Offset(-1.2 + _c.value * 3.0, 0),
          child: Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.white38, Colors.transparent])))));
}

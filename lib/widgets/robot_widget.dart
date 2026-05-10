// ============================================================
// MindEdge Robot Widget — Fixed v2
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ─── Main Robot (130 × 150) ──────────────────────────────────
class MainRobot extends StatefulWidget {
  const MainRobot({super.key});

  @override
  State<MainRobot> createState() => _MainRobotState();
}

class _MainRobotState extends State<MainRobot> with SingleTickerProviderStateMixin {
  late final AnimationController _blinkCtrl;
  late final Animation<double> _blinkScale;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(vsync: this, duration: AppDuration.blink)..repeat();
    _blinkScale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 92),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.1).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 4),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.1, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 4),
    ]).animate(_blinkCtrl);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _blinkScale,
        builder: (_, __) => CustomPaint(
          size: const Size(130, 150),
          painter: _MainRobotPainter(blinkScaleY: _blinkScale.value),
        ),
      ),
    );
  }
}

class _MainRobotPainter extends CustomPainter {
  final double blinkScaleY;
  const _MainRobotPainter({required this.blinkScaleY});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 130;

    // ── LEGS
    final legPaint = Paint()..color = const Color(0xFF6B4C3B);
    _rrect(canvas, Rect.fromLTWH(38 * s, 116 * s, 18 * s, 30 * s), 4 * s, legPaint);
    _rrect(canvas, Rect.fromLTWH(74 * s, 116 * s, 18 * s, 30 * s), 4 * s, legPaint);
    final footPaint = Paint()..color = const Color(0xFF7C5642);
    _rrect(canvas, Rect.fromLTWH(34 * s, 142 * s, 26 * s, 8 * s), 4 * s, footPaint);
    _rrect(canvas, Rect.fromLTWH(70 * s, 142 * s, 26 * s, 8 * s), 4 * s, footPaint);

    // ── BODY
    final bodyRect = Rect.fromLTWH(24 * s, 68 * s, 82 * s, 52 * s);
    _rrect(
        canvas,
        bodyRect,
        12 * s,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9A7060), Color(0xFF7C5642)],
          ).createShader(bodyRect));

    // Chest panel — withValues replaces withOpacity
    final panelRect = Rect.fromLTWH(36 * s, 78 * s, 58 * s, 32 * s);
    _rrect(
        canvas, panelRect, 8 * s, Paint()..color = const Color(0xFF2E1E17).withValues(alpha: 0.6));

    // AI label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'AI',
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 9 * s,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((65 - textPainter.width / 2) * s, 82 * s));

    // Chest lines
    final linePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.25)
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(41 * s, 96 * s), Offset(89 * s, 96 * s), linePaint);
    canvas.drawLine(Offset(41 * s, 101 * s), Offset(79 * s, 101 * s), linePaint);

    // ── ARMS
    final armPaint = Paint()..color = const Color(0xFF8B6656);
    _rrect(canvas, Rect.fromLTWH(10 * s, 74 * s, 14 * s, 36 * s), 7 * s, armPaint);
    _rrect(canvas, Rect.fromLTWH(106 * s, 74 * s, 14 * s, 36 * s), 7 * s, armPaint);
    final handPaint = Paint()..color = const Color(0xFF7C5642);
    canvas.drawCircle(Offset(17 * s, 114 * s), 7 * s, handPaint);
    canvas.drawCircle(Offset(113 * s, 114 * s), 7 * s, handPaint);

    // ── NECK
    _rrect(canvas, Rect.fromLTWH(56 * s, 58 * s, 18 * s, 14 * s), 5 * s,
        Paint()..color = const Color(0xFF7C5642));

    // ── EARS
    final earPaint = Paint()..color = const Color(0xFF8B6656);
    canvas.drawCircle(Offset(18 * s, 32 * s), 7 * s, earPaint);
    canvas.drawCircle(Offset(112 * s, 32 * s), 7 * s, earPaint);

    // ── ANTENNA
    canvas.drawLine(
      Offset(65 * s, 6 * s),
      Offset(65 * s, 18 * s),
      Paint()
        ..color = const Color(0xFF7C5642)
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(65 * s, 4 * s), 4 * s, Paint()..color = AppColors.gold);

    // ── HEAD
    final headRect = Rect.fromLTWH(16 * s, 12 * s, 98 * s, 50 * s);
    _rrect(
        canvas,
        headRect,
        18 * s,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB89080), Color(0xFF8B6656)],
          ).createShader(headRect));

    // ── EYES
    _drawEye(canvas, s, Offset(44 * s, 36 * s), blinkScaleY);
    _drawEye(canvas, s, Offset(86 * s, 36 * s), blinkScaleY);

    // ── SMILE
    final smilePath = Path()
      ..moveTo(50 * s, 52 * s)
      ..quadraticBezierTo(65 * s, 60 * s, 80 * s, 52 * s);
    canvas.drawPath(
        smilePath,
        Paint()
          ..color = const Color(0xFF4A3228).withValues(alpha: 0.5)
          ..strokeWidth = 2 * s
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  void _drawEye(Canvas canvas, double s, Offset center, double blinkScaleY) {
    canvas.save();
    // Use canvas.translate / canvas.scale (these are canvas methods, not deprecated)
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, blinkScaleY);

    final eyeRect = Rect.fromCenter(center: Offset.zero, width: 16 * s, height: 16 * s);
    canvas.drawOval(
        eyeRect,
        Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFFFAF6EE), AppColors.gold],
            radius: 0.8,
          ).createShader(eyeRect));

    canvas.drawCircle(
        Offset.zero, 5 * s, Paint()..color = const Color(0xFF4A3228).withValues(alpha: 0.7));
    canvas.drawCircle(
        Offset(-2 * s, -2 * s), 2 * s, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.restore();
  }

  void _rrect(Canvas canvas, Rect rect, double radius, Paint paint) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
  }

  @override
  bool shouldRepaint(_MainRobotPainter old) => old.blinkScaleY != blinkScaleY;
}

// ─── Companion Bot ────────────────────────────────────────────
class CompanionBot extends StatelessWidget {
  final double size;
  final double opacity;

  const CompanionBot({super.key, this.size = 32, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size * 1.1),
        painter: _CompanionBotPainter(),
      ),
    );
  }
}

class _CompanionBotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32;

    final bodyRect = Rect.fromLTWH(6 * s, 10 * s, 20 * s, 16 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(6 * s)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB89080), Color(0xFF8B6656)],
        ).createShader(bodyRect),
    );

    final headRect = Rect.fromLTWH(7 * s, 2 * s, 18 * s, 12 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(5 * s)),
      Paint()..color = const Color(0xFF9A7060),
    );

    canvas.drawCircle(Offset(13 * s, 8 * s), 2.5 * s, Paint()..color = AppColors.goldLight);
    canvas.drawCircle(Offset(19 * s, 8 * s), 2.5 * s, Paint()..color = AppColors.goldLight);

    canvas.drawLine(
        Offset(16 * s, 2 * s),
        Offset(16 * s, 0),
        Paint()
          ..color = const Color(0xFF7C5642)
          ..strokeWidth = 1.2 * s);
    canvas.drawCircle(Offset(16 * s, 0), 1.5 * s, Paint()..color = AppColors.gold);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(9 * s, 26 * s, 5 * s, 8 * s), Radius.circular(2 * s)),
      Paint()..color = const Color(0xFF7C5642),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(18 * s, 26 * s, 5 * s, 8 * s), Radius.circular(2 * s)),
      Paint()..color = const Color(0xFF7C5642),
    );
  }

  @override
  bool shouldRepaint(_CompanionBotPainter old) => false;
}

// ─── Book Widget — Proper continuous page-flip ────────────────
//
// Architecture:
//  • One AnimationController per page (left + right), each 3.6s, looping.
//  • TweenSequence drives: rest (0°) → flip out (−90°) → flip in (0°)
//    so each page appears to lift off, cross the spine, and settle.
//  • Matrix4 setEntry(3,2, perspectiveDepth) gives realistic 3-D depth.
//  • Shadow darkens as the page is mid-flip (angle near ±90°).
//  • RepaintBoundary isolates the whole book.
//  • Left page flips on a 0.5s offset; right page on 1.8s offset for
//    natural stagger — they never overlap exactly at 90°.
class BookWidget extends StatefulWidget {
  const BookWidget({super.key});

  @override
  State<BookWidget> createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> with TickerProviderStateMixin {
  late final AnimationController _leftCtrl;
  late final AnimationController _rightCtrl;
  // Angle in degrees driven by TweenSequence for each page
  late final Animation<double> _leftAngle;
  late final Animation<double> _rightAngle;
  // Shadow opacity — peaks at mid-flip
  late final Animation<double> _leftShadow;
  late final Animation<double> _rightShadow;

  static const double _perspective = 0.0008;

  @override
  void initState() {
    super.initState();

    _leftCtrl = AnimationController(vsync: this, duration: AppDuration.pageFlip);
    _rightCtrl = AnimationController(vsync: this, duration: AppDuration.pageFlip);

    // Left page: starts flat (0°), folds to −90° (edge-on), returns to 0°
    // TweenSequence: weight proportions control timing feel.
    _leftAngle = TweenSequence<double>([
      // Pause before flip starts
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
      // Accelerate out to edge-on
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -90.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      // Decelerate in from edge-on (page lands)
      TweenSequenceItem(
        tween: Tween<double>(begin: -90.0, end: -8.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // Slight spring-back settle to rest
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_leftCtrl);

    // Right page: mirror of left — flips to +90°
    _rightAngle = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 90.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 90.0, end: 8.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 8.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_rightCtrl);

    // Shadow: derive directly from the controller value (0..1), not the angle.
    // _leftCtrl.value goes 0→1 over the full cycle. Shadow peaks at mid-flip
    // which is roughly t=0.4 (when angle hits ±90°). Use a simple triangle.
    _leftShadow = _leftCtrl.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const _MidPeakCurve()),
      ),
    );
    _rightShadow = _rightCtrl.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: const _MidPeakCurve()),
      ),
    );

    // Left starts immediately, right starts 1.8s later for stagger
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _leftCtrl.repeat();
    });
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) _rightCtrl.repeat();
    });
  }

  @override
  void dispose() {
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 88,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Book cover / spine (always behind pages)
            _buildBookBase(),

            AnimatedBuilder(
              animation: _leftCtrl,
              builder: (_, __) {
                final angleRad = _leftAngle.value * math.pi / 180.0;
                final shadowAlpha = (_leftShadow.value * 0.35).clamp(0.0, 0.35);
                return Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, _perspective)
                    ..rotateY(angleRad),
                  child: _buildPage(isLeft: true, shadowAlpha: shadowAlpha),
                );
              },
            ),

            // Right page — rotates around its left edge
            AnimatedBuilder(
              animation: _rightCtrl,
              builder: (_, __) {
                final angleRad = _rightAngle.value * math.pi / 180.0;
                final shadowAlpha = (_rightShadow.value * 0.35).clamp(0.0, 0.35);
                return Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, _perspective)
                    ..rotateY(angleRad),
                  child: _buildPage(isLeft: false, shadowAlpha: shadowAlpha),
                );
              },
            ),

            // Spine line — always on top
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 3,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A3228), Color(0xFF2E1E17)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookBase() {
    return Container(
      width: 88,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B6656), Color(0xFF4A3228)],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A3228).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required bool isLeft, required double shadowAlpha}) {
    return ClipRect(
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        widthFactor: 0.90,
        child: Stack(
          children: [
            Container(
              width: 88,
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0DC),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simulated text lines
                  _line(0.85),
                  _line(1.0),
                  _line(0.70),
                  _line(0.90),
                  _line(0.60),
                ],
              ),
            ),
            // Dynamic shadow overlay — darkens as page lifts
            if (shadowAlpha > 0.01)
              Container(
                width: 88,
                height: 58,
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, shadowAlpha),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _line(double widthFraction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: FractionallySizedBox(
        widthFactor: widthFraction,
        alignment: Alignment.centerRight,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.cocoa.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

class _MidPeakCurve extends Curve {
  const _MidPeakCurve();

  @override
  double transformInternal(double t) {
    // Peak at t=0.40 — matches when the page reaches ±90° in the TweenSequence
    const peak = 0.40;
    if (t <= peak) return t / peak; // 0 → 1
    return (1.0 - t) / (1.0 - peak); // 1 → 0
  }
}

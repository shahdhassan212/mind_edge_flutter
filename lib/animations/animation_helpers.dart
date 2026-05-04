// ============================================================
// animations/animation_helpers.dart
// Complete animation widget library for MindEdge
// ============================================================
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// ── AppCurves ─────────────────────────────────────────────────
class AppCurves {
  AppCurves._();
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve loaderFill = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}

// ── ShimmerOverlay ────────────────────────────────────────────
class ShimmerOverlay extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final double shimmerOpacity;

  const ShimmerOverlay({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    this.delay = const Duration(milliseconds: 1500),
    this.shimmerOpacity = 0.07,
  });

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => FractionalTranslation(
        translation: Offset(-1.2 + _ctrl.value * 3.0, 0),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.white.withOpacity(widget.shimmerOpacity),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }
}

// ── GlowPulse ─────────────────────────────────────────────────
class GlowPulse extends StatefulWidget {
  final double width;
  final double height;

  const GlowPulse({super.key, this.width = 160, this.height = 44});

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: 0.45 + _ctrl.value * 0.30,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
              AppColors.gold.withOpacity(0.42),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }
}

// ── AntennaPulse ──────────────────────────────────────────────
class AntennaPulse extends StatefulWidget {
  final double size;

  const AntennaPulse({super.key, this.size = 6});

  @override
  State<AntennaPulse> createState() => _AntennaPulseState();
}

class _AntennaPulseState extends State<AntennaPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: 0.6 + _ctrl.value * 0.4,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.goldLight,
          ),
        ),
      ),
    );
  }
}

// ── FloatWidget ───────────────────────────────────────────────
class FloatWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double translateYMin;
  final double translateYMax;
  final double rotateMin;
  final double rotateMax;

  const FloatWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 4500),
    this.delay = Duration.zero,
    this.translateYMin = 0,
    this.translateYMax = -10,
    this.rotateMin = 0,
    this.rotateMax = 0.4,
  });

  @override
  State<FloatWidget> createState() => _FloatWidgetState();
}

class _FloatWidgetState extends State<FloatWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: AppCurves.easeInOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final t = _anim.value;
        final ty = widget.translateYMin + (widget.translateYMax - widget.translateYMin) * t;
        final rot = (widget.rotateMin + (widget.rotateMax - widget.rotateMin) * t) * math.pi / 180;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, ty)
            ..rotateZ(rot),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── FadeUpEntrance ────────────────────────────────────────────
class FadeUpEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeUpEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<FadeUpEntrance> createState() => _FadeUpEntranceState();
}

class _FadeUpEntranceState extends State<FadeUpEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── DotBreath ─────────────────────────────────────────────────
class DotBreath extends StatefulWidget {
  final Widget child;

  const DotBreath({super.key, required this.child});

  @override
  State<DotBreath> createState() => _DotBreathState();
}

class _DotBreathState extends State<DotBreath> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.scale(
        scaleX: 1.0 + _ctrl.value * 0.15,
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── AmbientRotate ─────────────────────────────────────────────
class AmbientRotate extends StatefulWidget {
  final Widget child;

  const AmbientRotate({super.key, required this.child});

  @override
  State<AmbientRotate> createState() => _AmbientRotateState();
}

class _AmbientRotateState extends State<AmbientRotate> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDuration.ambientRotate)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.rotate(
        angle: _ctrl.value * 2 * math.pi,
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── WaveformWidget ────────────────────────────────────────────
class WaveformWidget extends StatefulWidget {
  final int barCount;

  const WaveformWidget({super.key, this.barCount = 14});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _baseHeights = [
    10.0,
    22.0,
    16.0,
    30.0,
    12.0,
    22.0,
    36.0,
    10.0,
    28.0,
    18.0,
    42.0,
    14.0,
    22.0,
    10.0,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          math.min(widget.barCount, _baseHeights.length),
          (i) {
            final phase = (i / math.max(widget.barCount, 1)) * math.pi;
            final h = _baseHeights[i] * (0.6 + 0.4 * math.sin(_ctrl.value * math.pi + phase));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 4,
                height: h.clamp(3.0, 50.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.cocoa, AppColors.gold],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── ScanBeamWidget ────────────────────────────────────────────
class ScanBeamWidget extends StatefulWidget {
  const ScanBeamWidget({super.key});

  @override
  State<ScanBeamWidget> createState() => _ScanBeamWidgetState();
}

class _ScanBeamWidgetState extends State<ScanBeamWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppDuration.scan)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Positioned(
          top: 18 + t * (200 - 34),
          left: 0,
          right: 0,
          height: 2,
          child: Opacity(
            opacity: (1 - t * 0.5).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.gold.withOpacity(0.7),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}

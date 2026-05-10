// ============================================================
// Page 12 — Scan Document (live camera UI)
// ============================================================
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  int _tab = 0;
  late AnimationController _beamCtrl;
  late Animation<double> _beamAnim;
  double _progress = 0.64;

  // ── Camera state ──────────────────────────────────────────
  CameraController? _camCtrl;
  List<CameraDescription> _cameras = [];
  int _camIndex = 0;
  bool _camReady = false;
  bool _flashOn = false;
  String? _camError;

  @override
  void initState() {
    super.initState();
    _beamCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _beamAnim = CurvedAnimation(parent: _beamCtrl, curve: Curves.easeInOut);
    _initCamera();
  }

  // ── Camera helpers ────────────────────────────────────────
  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (!status.isGranted) {
      setState(() => _camError = 'Camera permission denied.\nTap to open settings.');
      return;
    }

    try {
      _cameras = await availableCameras();
    } catch (e) {
      if (mounted) setState(() => _camError = 'No cameras found: $e');
      return;
    }

    if (_cameras.isEmpty) {
      if (mounted) setState(() => _camError = 'No cameras available on this device.');
      return;
    }

    await _startCamera(_camIndex);
  }

  Future<void> _startCamera(int index) async {
    await _camCtrl?.dispose();
    setState(() {
      _camReady = false;
      _camError = null;
    });

    final cam = _cameras[index.clamp(0, _cameras.length - 1)];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      _camCtrl = ctrl;
      setState(() {
        _camReady = true;
        _camIndex = index;
      });
    } on CameraException catch (e) {
      await ctrl.dispose();
      if (mounted) setState(() => _camError = '${e.code}: ${e.description}');
    }
  }

  Future<void> _toggleFlash() async {
    if (_camCtrl == null || !_camReady) return;
    _flashOn = !_flashOn;
    await _camCtrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    await _startCamera((_camIndex + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    if (_camCtrl == null || !_camReady) return;
    try {
      final xFile = await _camCtrl!.takePicture();
      if (!mounted) return;
      Navigator.pushNamed(context, '/ocr-processing', arguments: xFile.path);
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Capture failed: ${e.description}')));
      }
    }
  }

  @override
  void dispose() {
    _beamCtrl.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0905),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          Color(0xFF0E0905),
          Color(0xFF1A1008),
          Color(0xFF0E0905),
        ])),
        child: SafeArea(
          child: Column(children: [
            // ── Nav ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: Row(children: [
                _DarkNavBtn(
                    child: const Text('←',
                        style: TextStyle(fontSize: 16, color: AppColors.goldLight))),
                const Spacer(),
                const Text('Scan Document',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD9CCB5))),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleFlash,
                  child: _DarkNavBtn(
                      child: Text('⚡',
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  _flashOn ? AppColors.gold : AppColors.gold.withOpacity(0.35)))),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // ── Camera zone ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0704),
                    border: Border.all(color: AppColors.gold.withOpacity(0.18), width: 1.5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(children: [
                    // Live preview
                    Positioned.fill(child: _buildCameraPreview()),

                    // Corner brackets
                    ..._corners(),

                    // Scan beam
                    if (_camReady)
                      AnimatedBuilder(
                        animation: _beamAnim,
                        builder: (_, __) {
                          final y = 18 + (_beamAnim.value * (220 - 34));
                          return Positioned(
                            top: y,
                            left: 14,
                            right: 14,
                            height: 2,
                            child: Opacity(
                              opacity: (1 - _beamAnim.value * 0.5),
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Colors.transparent,
                                  AppColors.gold.withOpacity(0.8),
                                  Colors.transparent,
                                ])),
                              ),
                            ),
                          );
                        },
                      ),

                    // OCR badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cocoaDeep.withOpacity(0.75),
                          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          _PulsingDot(),
                          const SizedBox(width: 5),
                          Text(
                            _camReady ? 'OCR Active' : 'Initializing…',
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldLight,
                                letterSpacing: 0.6),
                          ),
                        ]),
                      ),
                    ),

                    // Bottom bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Color(0xD90A0704),
                              Colors.transparent,
                            ])),
                        child: Row(children: [
                          Text('Detection confidence',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: AppColors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w300)),
                          const Spacer(),
                          const Text('98.4%',
                              style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldLight)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Tab strip ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: AppColors.gold.withOpacity(0.14)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                    children: ['Camera', 'Gallery', 'PDF / File']
                        .asMap()
                        .map((i, label) {
                          final on = i == _tab;
                          return MapEntry(
                              i,
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _tab = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: on
                                          ? AppColors.gold.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 11,
                                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                                            color: on
                                                ? AppColors.goldLight
                                                : AppColors.white.withOpacity(0.4))),
                                  ),
                                ),
                              ));
                        })
                        .values
                        .toList()),
              ),
            ),

            const SizedBox(height: 18),

            // ── Shutter row ───────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _CamControl(icon: '🔦', label: 'Flash', active: _flashOn, onTap: _toggleFlash),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _camReady ? _capture : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _camReady ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.25),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 32),
                      BoxShadow(
                          color: Colors.white.withOpacity(0.06), blurRadius: 0, spreadRadius: 8),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _camReady
                              ? Colors.white.withOpacity(0.95)
                              : Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _CamControl(icon: '⇄', label: 'Flip', active: false, onTap: _flipCamera),
            ]),

            const SizedBox(height: 14),

            // ── AI processing strip ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: AppColors.gold.withOpacity(0.18)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      border: Border.all(color: AppColors.gold.withOpacity(0.22)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('✦', style: TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('AI Analyzing Document',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white.withOpacity(0.85))),
                      const SizedBox(height: 2),
                      Text('Extracting text, structure, and topics…',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10.5,
                              color: AppColors.white.withOpacity(0.4),
                              fontWeight: FontWeight.w300)),
                      const SizedBox(height: 8),
                      _ProgressBar(value: _progress),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Text('${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold)),
                ]),
              ),
            ),

            const SizedBox(height: 12),
            Text('Hold camera steady · Multi-page supported',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w300)),
          ]),
        ),
      ),
    );
  }

  // ── Camera preview / states ───────────────────────────────
  Widget _buildCameraPreview() {
    if (_camError != null) {
      return GestureDetector(
        onTap: () => _camError!.contains('denied') ? openAppSettings() : _initCamera(),
        child: Container(
          color: const Color(0xFF0A0704),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.gold.withOpacity(0.4)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(_camError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        color: AppColors.white.withOpacity(0.45),
                        height: 1.5)),
              ),
              const SizedBox(height: 8),
              Text('Tap to retry',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      color: AppColors.gold.withOpacity(0.6))),
            ]),
          ),
        ),
      );
    }

    if (!_camReady || _camCtrl == null) {
      return Container(
        color: const Color(0xFF0A0704),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold.withOpacity(0.6)),
            ),
            const SizedBox(height: 10),
            Text('Starting camera…',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 11, color: AppColors.white.withOpacity(0.35))),
          ]),
        ),
      );
    }

    return CameraPreview(_camCtrl!);
  }

  List<Widget> _corners() {
    const c = Color(0xFFB48C50);
    const op = 0.7;
    return [
      Positioned(top: 14, left: 14, child: _Corner(tl: true, color: c.withOpacity(op))),
      Positioned(top: 14, right: 14, child: _Corner(tr: true, color: c.withOpacity(op))),
      Positioned(bottom: 14, left: 14, child: _Corner(bl: true, color: c.withOpacity(op))),
      Positioned(bottom: 14, right: 14, child: _Corner(br: true, color: c.withOpacity(op))),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final bool tl, tr, bl, br;
  final Color color;
  const _Corner(
      {this.tl = false, this.tr = false, this.bl = false, this.br = false, required this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _CornerPainter(tl: tl, tr: tr, bl: bl, br: br, color: color)));
}

class _CornerPainter extends CustomPainter {
  final bool tl, tr, bl, br;
  final Color color;
  const _CornerPainter(
      {required this.tl,
      required this.tr,
      required this.bl,
      required this.br,
      required this.color});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    if (tl) {
      c.drawLine(Offset(0, s.height * .5), const Offset(0, 4), p);
      c.drawArc(const Rect.fromLTWH(0, 0, 8, 8), -3.14 / 2, 3.14 / 2, false, p);
      c.drawLine(const Offset(4, 0), Offset(s.width * .5, 0), p);
    }
    if (tr) {
      c.drawLine(Offset(s.width * .5, 0), Offset(s.width - 4, 0), p);
      c.drawArc(Rect.fromLTWH(s.width - 8, 0, 8, 8), 0, -3.14 / 2, false, p);
      c.drawLine(Offset(s.width, 4), Offset(s.width, s.height * .5), p);
    }
    if (bl) {
      c.drawLine(Offset(0, s.height * .5), Offset(0, s.height - 4), p);
      c.drawArc(Rect.fromLTWH(0, s.height - 8, 8, 8), 3.14 / 2, 3.14 / 2, false, p);
      c.drawLine(Offset(4, s.height), Offset(s.width * .5, s.height), p);
    }
    if (br) {
      c.drawLine(Offset(s.width * .5, s.height), Offset(s.width - 4, s.height), p);
      c.drawArc(Rect.fromLTWH(s.width - 8, s.height - 8, 8, 8), 0, 3.14 / 2, false, p);
      c.drawLine(Offset(s.width, s.height - 4), Offset(s.width, s.height * .5), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CamControl extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CamControl(
      {required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.gold.withOpacity(0.18) : Colors.white.withOpacity(0.07),
              border: Border.all(
                  color: active ? AppColors.gold.withOpacity(0.5) : AppColors.gold.withOpacity(0.2),
                  width: 1.5),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 10.5, color: AppColors.white.withOpacity(0.5))),
        ]),
      );
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});
  @override
  Widget build(BuildContext context) => Container(
        height: 3,
        decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(2)),
        child: FractionallySizedBox(
          widthFactor: value,
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(children: [
              Container(decoration: const BoxDecoration(gradient: AppGradients.progress)),
              ShimmerOverlay(
                  duration: const Duration(milliseconds: 1600),
                  delay: Duration.zero,
                  shimmerOpacity: 0.4),
            ]),
          ),
        ),
      );
}

class _DarkNavBtn extends StatelessWidget {
  final Widget child;
  const _DarkNavBtn({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      );
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
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
              width: 5,
              height: 5,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold))));
}

// screens/audio_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class AudioLesson {
  final String audioUrl;
  final String summary;
  final String displayName;
  const AudioLesson({
    required this.audioUrl,
    required this.summary,
    required this.displayName,
  });
}

const _kAudioBaseUrl = 'https://midedge.runasp.net';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with SingleTickerProviderStateMixin {
  AudioLesson? _lesson;
  bool _loading = true;
  String? _error;

  final _player = AudioPlayer();
  bool _captions = true;
  int _speedIdx = 1;
  static const _speeds = [1.0, 1.5, 2.0];

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;

  late final AnimationController _wfCtrl;
  late final List<StreamSubscription> _subs;

  static const _wfPlayedH = [14.0, 24.0, 32.0, 18.0, 28.0, 12.0];
  static const _wfActiveH = 36.0;
  static const _wfUnplayedH = [
    20.0,
    30.0,
    16.0,
    24.0,
    10.0,
    18.0,
    26.0,
    8.0,
    22.0,
    34.0,
    14.0,
    28.0,
    12.0,
  ];

  @override
  void initState() {
    super.initState();
    _wfCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    _subs = [
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.durationStream.listen((d) {
        if (d != null && mounted) setState(() => _duration = d);
      }),
      _player.playingStream.listen((v) {
        if (mounted) setState(() => _playing = v);
      }),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lesson == null) _loadLesson();
  }

  Future<void> _loadLesson() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) {
      return _fail('No audio data was provided.');
    }
    final rawUrl = args['audioUrl']?.toString() ?? '';
    final summary = args['summary']?.toString() ?? '';
    final displayName = args['displayName']?.toString() ?? '';
    if (rawUrl.isEmpty) return _fail('Audio URL is missing.');

    final url = rawUrl.startsWith('http') ? rawUrl : '$_kAudioBaseUrl$rawUrl';

    if (!mounted) return;
    setState(() {
      _lesson = AudioLesson(audioUrl: url, summary: summary, displayName: displayName);
      _loading = false;
    });

    try {
      await _player.setUrl(url);
      await _player.setSpeed(_speeds[_speedIdx]);
      await _player.play();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _fail(String msg) {
    if (mounted)
      setState(() {
        _error = msg;
        _loading = false;
      });
  }

  @override
  void dispose() {
    _wfCtrl.dispose();
    for (final s in _subs) s.cancel();
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  double get _progress => _duration.inMilliseconds == 0
      ? 0
      : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

  Future<void> _seek(double factor) =>
      _player.seek(Duration(milliseconds: (factor * _duration.inMilliseconds).round()));

  Future<void> _skip(Duration delta) async {
    final ms = (_position + delta).inMilliseconds.clamp(0, _duration.inMilliseconds);
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> _setSpeed(int i) async {
    setState(() => _speedIdx = i);
    await _player.setSpeed(_speeds[i]);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoader();
    if (_error != null) return _buildError();
    final lesson = _lesson!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              AppColors.dashBgTop,
              AppColors.dashBgMid,
              AppColors.dashBgBottom,
            ],
          ),
        ),
        child: Stack(children: [
          AppDecorOrb(
              top: -60, right: -60, size: 240, color: AppColors.dashGoldLight.withOpacity(0.18)),
          SafeArea(
            child: Column(children: [
              _buildNav(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(children: [
                    _buildTopicCard(lesson),
                    _buildControls(),
                    if (_captions) _buildTranscript(lesson),
                    _buildPlayer(),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildNav() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
        child: Row(children: [
          AppBackButton(onTap: () => Navigator.pop(context)),
          const Spacer(),
          const Text('Audio Explanation',
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
              border: Border.all(color: AppColors.dashBorder.withOpacity(0.4)),
              boxShadow: AppShadows.sm,
            ),
            child: const Center(
              child: Text('⋯', style: TextStyle(fontSize: 13, color: AppColors.cocoa)),
            ),
          ),
        ]),
      );

  Widget _buildTopicCard(AudioLesson lesson) => Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            gradient: AppGradients.ctaButtonFinal,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cocoa.withOpacity(0.25),
                  blurRadius: 36,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: Stack(children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AUDIO EXPLANATION',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.4)),
                const SizedBox(height: 5),
                Text(lesson.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.25)),
                const SizedBox(height: 4),
                Text(
                  _duration > Duration.zero
                      ? 'Generated from your uploaded notes · ${_fmt(_duration)}'
                      : 'Generated from your uploaded notes',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
            Positioned(right: 0, bottom: 0, child: _FloatingMiniBot()),
          ]),
        ),
      );

  // ─── Speed + captions ──────────────────────────────────────
  Widget _buildControls() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Row(children: [
          Row(
            children: ['1×', '1.5×', '2×'].asMap().entries.map((e) {
              final active = e.key == _speedIdx;
              return GestureDetector(
                onTap: () => _setSpeed(e.key),
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 2 ? 5 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [Color(0xFF4A2C14), AppColors.audioCardDark2])
                          : null,
                      color: active ? null : AppColors.cocoa.withOpacity(0.08),
                      border: Border.all(
                          color: active ? Colors.transparent : AppColors.cocoa.withOpacity(0.16)),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: AppColors.cocoaDeep.withOpacity(0.22),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ]
                          : null,
                    ),
                    child: Text(e.value,
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppColors.cocoa)),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _captions = !_captions),
            child: Row(children: [
              _Toggle(on: _captions),
              const SizedBox(width: 7),
              const Text('Captions',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cocoa)),
            ]),
          ),
        ]),
      );

  // ─── Transcript ────────────────────────────────────────────
  Widget _buildTranscript(AudioLesson lesson) => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            border: Border.all(color: AppColors.dashBorder.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRANSCRIPT',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: AppColors.muted)),
              const SizedBox(height: 8),
              SelectableText(
                lesson.summary.isNotEmpty ? lesson.summary : 'No transcript available.',
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.cocoaDeep,
                    height: 1.65),
              ),
            ],
          ),
        ),
      );

  // ─── Player card ───────────────────────────────────────────
  Widget _buildPlayer() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.62),
            border: Border.all(color: AppColors.dashBorder.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cocoaDeep.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(children: [
            _buildWaveform(),
            const SizedBox(height: 12),
            _buildScrubber(),
            const SizedBox(height: 14),
            _buildPlayControls(),
          ]),
        ),
      );

  // ─── Waveform ──────────────────────────────────────────────
  Widget _buildWaveform() => AnimatedBuilder(
        animation: _wfCtrl,
        builder: (_, __) => SizedBox(
          height: 42,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ..._wfPlayedH.map((h) => _WfBar(height: h, played: true)),
              _WfBar(height: _wfActiveH + _wfCtrl.value * 10, played: true),
              ..._wfUnplayedH.map((h) => _WfBar(height: h, played: false)),
            ],
          ),
        ),
      );

  // ─── Scrubber ──────────────────────────────────────────────
  Widget _buildScrubber() => Row(children: [
        Text(_fmt(_position),
            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.muted)),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
              builder: (_, cst) => GestureDetector(
                    onTapDown: (d) => _seek(d.localPosition.dx / cst.maxWidth),
                    onHorizontalDragUpdate: (d) =>
                        _seek((_progress * cst.maxWidth + d.delta.dx) / cst.maxWidth),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Container(
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.dashBorder, borderRadius: BorderRadius.circular(2))),
                      FractionallySizedBox(
                        widthFactor: _progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColors.audioCardDark2,
                              AppColors.dashGoldDark,
                            ]),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (_progress * cst.maxWidth - 6).clamp(-6.0, cst.maxWidth - 6),
                        top: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cocoa,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.cocoa.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                        ),
                      ),
                    ]),
                  )),
        ),
        const SizedBox(width: 10),
        Text(_fmt(_duration),
            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.muted)),
      ]);

  // ─── Play controls ─────────────────────────────────────────
  Widget _buildPlayControls() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CtrlBtn(label: '«', onTap: () => _skip(const Duration(seconds: -10))),
          _CtrlBtn(label: '‹', onTap: () => _skip(const Duration(seconds: -5))),
          GestureDetector(
            onTap: () => _playing ? _player.pause() : _player.play(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A2C14), AppColors.audioCardDark2]),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.audioCardDark2.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(_playing ? '⏸' : '▶',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
          _CtrlBtn(label: '›', onTap: () => _skip(const Duration(seconds: 5))),
          _CtrlBtn(label: '»', onTap: () => _skip(const Duration(seconds: 10))),
        ],
      );

  // ─── Loading / Error ───────────────────────────────────────
  Widget _buildLoader() => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
        ),
      );

  Widget _buildError() => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.gold),
              const SizedBox(height: 12),
              Text(_error ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'DM Sans', fontSize: 13, color: Color(0xFF6B4C3B))),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loadLesson,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  decoration: BoxDecoration(
                      color: AppColors.cocoaDeep, borderRadius: BorderRadius.circular(12)),
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
      );
}

// ─── Toggle switch ─────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool on;
  const _Toggle({required this.on});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient:
              on ? const LinearGradient(colors: [Color(0xFF6B3A2A), AppColors.dashGoldDark]) : null,
          color: on ? null : AppColors.cocoa.withOpacity(0.15),
          boxShadow: on
              ? [
                  BoxShadow(
                      color: AppColors.cocoa.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Align(
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      );
}

// ─── Waveform bar ──────────────────────────────────────────────
class _WfBar extends StatelessWidget {
  final double height;
  final bool played;
  const _WfBar({required this.height, required this.played});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: played
                  ? const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                          AppColors.audioCardDark2,
                          AppColors.dashGoldDark,
                        ])
                  : null,
              color: played ? null : AppColors.audioWfUnplayed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}

// ─── Control button ────────────────────────────────────────────
class _CtrlBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CtrlBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cocoa.withOpacity(0.08),
            border: Border.all(color: AppColors.cocoa.withOpacity(0.18)),
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.cocoa)),
          ),
        ),
      );
}

// ─── Floating mini bot ─────────────────────────────────────────
class _FloatingMiniBot extends StatefulWidget {
  @override
  State<_FloatingMiniBot> createState() => _FloatingMiniBotState();
}

class _FloatingMiniBotState extends State<_FloatingMiniBot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -5 * _anim.value),
          child: SizedBox(
            width: 34,
            height: 38,
            child: CustomPaint(painter: _MiniBotPainter()),
          ),
        ),
      );
}

class _MiniBotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.dashGoldDark.withOpacity(0.55);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(6, 11, 22, 18), const Radius.circular(6)), p);
    p.color = AppColors.dashGoldDark.withOpacity(0.4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(10, 2, 14, 12), const Radius.circular(4)), p);
    p
      ..color = AppColors.dashGoldDark.withOpacity(0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(17, 2), const Offset(17, 0), p);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(17, 0), 2, p);
    p.color = AppColors.white;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(12, 5, 4, 4), const Radius.circular(2)), p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(18, 5, 4, 4), const Radius.circular(2)), p);
    p.color = AppColors.white.withOpacity(0.7);
    canvas.drawCircle(const Offset(14, 20), 2, p);
    canvas.drawCircle(const Offset(20, 20), 2, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

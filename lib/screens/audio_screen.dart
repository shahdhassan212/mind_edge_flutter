// ============================================================
// Page 17 — Audio Explanation Player
// • Receives audioUrl + summary + displayName via route arguments
//   (sent from ai_analysis_screen after /api/Document/process-audio)
// • just_audio for real playback


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ─────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────
class _C {
  // Background — matches dashboard warm cream gradient
  static const bg1 = Color(0xFFF7EDD8);
  static const bg2 = Color(0xFFF0E0C0);
  static const bg3 = Color(0xFFE8D0A8);
  static const cardDark = Color(0xFF3D2510);
  static const cardDark2 = Color(0xFF2A1A0E);
  static const white = Colors.white;
  // Gold — matches dashboard goldDark / goldLight exactly
  static const gold = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  // Primary text — dashboard textDark (high contrast on cream)
  static const cocoa = Color(0xFF2A1A0E);
  static const cocoaDeep = Color(0xFF2A1A0E);
  // Muted text — dashboard textMuted
  static const muted = Color(0xFF9E8A72);
  // Body text — dashboard textDark (strong contrast)
  static const textBody = Color(0xFF2A1A0E);
  static const cardBg = Color(0xFFFEFCF7);
  // Border — matches dashboard statBorder
  static const border = Color(0xFFE8D9C0);
  // Waveform played — dark espresso for high contrast
  static const wfPlayed1 = Color(0xFF2A1A0E);
  static const wfPlayed2 = Color(0xFFC9943A);
  static const wfUnplayed = Color(0xFFD6C4A8);
  // Scrubber — matches dashboard progress bar approach
  static const scrubTrack = Color(0xFFE8D9C0);
  static const scrubFill1 = Color(0xFF2A1A0E);
  static const scrubFill2 = Color(0xFFC9943A);
}

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────
class AudioLesson {
  final String audioUrl;     // absolute URL to the MP3
  final String summary;      // transcript — what the audio reads
  final String displayName;  // file name shown as the card title

  const AudioLesson({
    required this.audioUrl,
    required this.summary,
    required this.displayName,
  });
}

// Backend serves audio under this host; the API returns a relative path
// like "/audio/<hash>.mp3", which we join with this base.
const _kAudioBaseUrl = 'https://midedge.runasp.net';

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────
  AudioLesson? _lesson;
  bool _loading = true;
  String? _error;

  final _player = AudioPlayer();

  bool _captions = true;
  int _speedIdx = 1; // 0=1× 1=1.5× 2=2×
  static const _speeds = [1.0, 1.5, 2.0];

  // Playback driven by just_audio streams
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;

  // Waveform animation controller for active bar
  late AnimationController _wfCtrl;

  // Waveform bar heights
  static const _wfPlayed = [14.0, 24.0, 32.0, 18.0, 28.0, 12.0];
  static const _wfActive = 36.0;
  static const _wfUnplayed = [
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
    12.0
  ];

  late final List<StreamSubscription> _subs;

  // ── Init ──────────────────────────────────────────────────
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
      if (mounted) {
        setState(() {
          _error = 'No audio data was provided.';
          _loading = false;
        });
      }
      return;
    }
    final rawUrl = args['audioUrl']?.toString() ?? '';
    final summary = args['summary']?.toString() ?? '';
    final displayName = args['displayName']?.toString() ?? '';
    if (rawUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'Audio URL is missing.';
          _loading = false;
        });
      }
      return;
    }

    final audioUrl =
        rawUrl.startsWith('http') ? rawUrl : '$_kAudioBaseUrl$rawUrl';

    final lesson = AudioLesson(
      audioUrl: audioUrl,
      summary: summary,
      displayName: displayName,
    );

    if (!mounted) return;
    setState(() {
      _lesson = lesson;
      _loading = false;
    });

    try {
      await _player.setUrl(audioUrl);
      await _player.setSpeed(_speeds[_speedIdx]);
      await _player.play();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  // ── Dispose ───────────────────────────────────────────────
  @override
  void dispose() {
    _wfCtrl.dispose();
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────
  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  double get _progress => _duration.inMilliseconds == 0
      ? 0
      : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

  Future<void> _seek(double factor) async {
    final ms = (factor * _duration.inMilliseconds).round();
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> _skip(Duration delta) async {
    final target = _position + delta;
    await _player
        .seek(Duration(milliseconds: target.inMilliseconds.clamp(0, _duration.inMilliseconds)));
  }

  Future<void> _setSpeed(int idx) async {
    setState(() => _speedIdx = idx);
    await _player.setSpeed(_speeds[idx]);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoader();
    if (_error != null) return _buildError();
    final lesson = _lesson!;

    return Scaffold(
      backgroundColor: _C.bg1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8), // top — light cream (dashboard bgTop)
              Color(0xFFF0E0C0), // mid — warm sand (dashboard mid)
              Color(0xFFE8D0A8), // bottom — deeper tan (dashboard bgBottom)
            ],
          ),
        ),
        child: Stack(children: [
          // 2. الدائرة الضوئية (Ambient circle) باللون الذهبي المعتمد
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _C.goldLight.withValues(alpha: 0.18), // matches dashboard ambient orb
                    Colors.transparent,
                  ],
                  radius: 0.68,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(children: [
              _buildNav(), // تأكدي إن أيقونة الرجوع لونها بني 0xFF7C5642
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

  // ── Nav ───────────────────────────────────────────────────
  Widget _buildNav() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
        child: Row(children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _C.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                      color: _C.cocoaDeep.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Center(
                child: Text('←', style: TextStyle(fontSize: 16, color: _C.cocoaDeep)),
              ),
            ),
          ),
          const Spacer(),
          const Text('Audio Explanation',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.cocoaDeep)),
          const Spacer(),
          // More button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.border.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: _C.cocoaDeep.withOpacity(0.06), blurRadius: 6)],
            ),
            child: const Center(
              child: Text('⋯', style: TextStyle(fontSize: 13, color: _C.cocoa)),
            ),
          ),
        ]),
      );

  // ── Topic card ────────────────────────────────────────────
  Widget _buildTopicCard(AudioLesson lesson) => Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            // 1. استخدام التدرج المرجعي (البيج/الذهبي للبني)
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // ظل بني ناعم متناسق مع المرجع
                color: const Color(0xFF7C5642).withOpacity(0.25),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(children: [
            // 2. الدائرة الداخلية بلون فاتح عشان تدي إضاءة للكارت
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      fontWeight: FontWeight.w400)),
            ]),
            // الـ Mini Robot هيفضل مكانه وهيظهر بشكل أجمل على التدرج الجديد
            Positioned(
              right: 0,
              bottom: 0,
              child: _FloatingMiniBot(),
            ),
          ]),
        ),
      );

  // ── Speed pills + captions toggle ─────────────────────────
  Widget _buildControls() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Row(children: [
          // Speed pills
          Row(
              children: ['1×', '1.5×', '2×'].asMap().entries.map((e) {
            final i = e.key;
            final label = e.value;
            final active = i == _speedIdx;
            return GestureDetector(
              onTap: () => _setSpeed(i),
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(colors: [Color(0xFF4A2C14), Color(0xFF2A1A0E)])
                        : null,
                    color: active ? null : _C.cocoa.withOpacity(0.08),
                    border:
                        Border.all(color: active ? Colors.transparent : _C.cocoa.withOpacity(0.16)),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: _C.cocoaDeep.withOpacity(0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: active ? _C.white : _C.cocoa)),
                ),
              ),
            );
          }).toList()),
          const Spacer(),
          // Captions toggle
          GestureDetector(
            onTap: () => setState(() => _captions = !_captions),
            child: Row(children: [
              _buildToggle(_captions),
              const SizedBox(width: 7),
              const Text('Captions',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.cocoa)),
            ]),
          ),
        ]),
      );

  Widget _buildToggle(bool on) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient:
              on ? const LinearGradient(colors: [Color(0xFF6B3A2A), Color(0xFFC9943A)]) : null,
          color: on ? null : _C.cocoa.withOpacity(0.15),
          boxShadow: on
              ? [
                  BoxShadow(
                      color: _C.cocoa.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))
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
              color: _C.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      );

  // ── Live transcript ───────────────────────────────────────
  Widget _buildTranscript(AudioLesson lesson) => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: _C.white.withOpacity(0.58),
            border: Border.all(color: _C.border.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: _C.cocoaDeep.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TRANSCRIPT',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: _C.muted)),
            const SizedBox(height: 8),
            SelectableText(
              lesson.summary.isNotEmpty
                  ? lesson.summary
                  : 'No transcript available.',
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _C.textBody,
                  height: 1.65),
            ),
          ]),
        ),
      );

  // ── Player card ───────────────────────────────────────────
  Widget _buildPlayer() => Padding(
        padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: _C.white.withOpacity(0.62),
            border: Border.all(color: _C.border.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: _C.cocoaDeep.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4))
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

  // ── Waveform ──────────────────────────────────────────────
  Widget _buildWaveform() => AnimatedBuilder(
        animation: _wfCtrl,
        builder: (_, __) {
          return SizedBox(
            height: 42,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._wfPlayed.map((h) => _WfBar(height: h, played: true, active: false, animVal: 0)),
                _WfBar(
                    height: _wfActive + _wfCtrl.value * 10,
                    played: true,
                    active: true,
                    animVal: _wfCtrl.value),
                ..._wfUnplayed
                    .map((h) => _WfBar(height: h, played: false, active: false, animVal: 0)),
              ],
            ),
          );
        },
      );

  // ── Scrubber ──────────────────────────────────────────────
  Widget _buildScrubber() {
    return Row(children: [
      Text(_fmt(_position),
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: _C.muted)),
      const SizedBox(width: 10),
      Expanded(
        child: LayoutBuilder(builder: (ctx, cst) {
          return GestureDetector(
            onTapDown: (d) => _seek(d.localPosition.dx / cst.maxWidth),
            onHorizontalDragUpdate: (d) =>
                _seek(((_progress * cst.maxWidth) + d.delta.dx) / cst.maxWidth),
            child: Stack(clipBehavior: Clip.none, children: [
              // Track
              Container(
                height: 4,
                decoration:
                    BoxDecoration(color: _C.scrubTrack, borderRadius: BorderRadius.circular(2)),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_C.scrubFill1, _C.scrubFill2]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Thumb
              Positioned(
                left: (_progress * cst.maxWidth - 6).clamp(-6.0, cst.maxWidth - 6),
                top: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.cocoa,
                    boxShadow: [
                      BoxShadow(
                          color: _C.cocoa.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ]),
          );
        }),
      ),
      const SizedBox(width: 10),
      Text(_fmt(_duration),
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: _C.muted)),
    ]);
  }

  // ── Play controls ─────────────────────────────────────────
  Widget _buildPlayControls() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CtrlBtn(label: '«', onTap: () => _skip(const Duration(seconds: -10))),
          _CtrlBtn(label: '‹', onTap: () => _skip(const Duration(seconds: -5))),
          // Play/Pause
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
                    colors: [Color(0xFF4A2C14), Color(0xFF2A1A0E)]),
                boxShadow: [
                  BoxShadow(
                      color: _C.cardDark2.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(
                  _playing ? '⏸' : '▶',
                  style: const TextStyle(fontSize: 18, color: _C.white),
                ),
              ),
            ),
          ),
          _CtrlBtn(label: '›', onTap: () => _skip(const Duration(seconds: 5))),
          _CtrlBtn(label: '»', onTap: () => _skip(const Duration(seconds: 10))),
        ],
      );

  // ── Loading / error ───────────────────────────────────────
  Widget _buildLoader() => const Scaffold(
        backgroundColor: Color(0xFFFAF4E8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC9943A), strokeWidth: 2),
        ),
      );

  Widget _buildError() => Scaffold(
        backgroundColor: const Color(0xFFFAF4E8),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 32, color: Color(0xFFC9943A)),
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
                      color: const Color(0xFF2A1A0E), borderRadius: BorderRadius.circular(12)),
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

// ─────────────────────────────────────────────────────────────
// WAVEFORM BAR
// ─────────────────────────────────────────────────────────────
class _WfBar extends StatelessWidget {
  final double height;
  final bool played;
  final bool active;
  final double animVal;
  const _WfBar({
    required this.height,
    required this.played,
    required this.active,
    required this.animVal,
  });

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
                      colors: [_C.wfPlayed1, _C.wfPlayed2])
                  : null,
              color: played ? null : _C.wfUnplayed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// CONTROL BUTTON
// ─────────────────────────────────────────────────────────────
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
            color: _C.cocoa.withOpacity(0.08),
            border: Border.all(color: _C.cocoa.withOpacity(0.18)),
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 14, color: _C.cocoa)),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FLOATING MINI BOT
// ─────────────────────────────────────────────────────────────
class _FloatingMiniBot extends StatefulWidget {
  @override
  State<_FloatingMiniBot> createState() => _FloatingMiniBotState();
}

class _FloatingMiniBotState extends State<_FloatingMiniBot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _anim;

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
    final p = Paint()..color = const Color(0xFFC9943A).withOpacity(0.55);
    // Body
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(6, 11, 22, 18), const Radius.circular(6)), p);
    // Head
    p.color = const Color(0xFFC9943A).withOpacity(0.4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(10, 2, 14, 12), const Radius.circular(4)), p);
    // Antenna
    p.color = const Color(0xFFC9943A).withOpacity(0.55);
    p.strokeWidth = 1.5;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(17, 2), const Offset(17, 0), p);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(17, 0), 2, p);
    // Eyes
    p.color = const Color(0xFFFAF6EE);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(12, 5, 4, 4), const Radius.circular(2)), p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(18, 5, 4, 4), const Radius.circular(2)), p);
    // Belly buttons
    p.color = const Color(0xFFFAF6EE).withOpacity(0.7);
    canvas.drawCircle(const Offset(14, 20), 2, p);
    canvas.drawCircle(const Offset(20, 20), 2, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

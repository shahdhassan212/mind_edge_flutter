import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/model/analysis_models.dart';
import '../features/analysis/providers/analysis_providersl.dart';

// ─────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const pageBg = Color(0xFFF4EDE0);
  static const cardBg = Color(0xFFFEFCF7);
  static const heroCard = Color(0xFF201410);
  static const textDark = Color(0xFF2A1A0E);
  static const textBody = Color(0xFF3A2410);
  static const textMuted = Color(0xFF9E8A72);
  static const textHint = Color(0xFFB8A88A);
  static const goldDark = Color(0xFFC9943A);
  static const goldLight = Color(0xFFE8B84B);
  static const border = Color(0xFFE8D9C0);
  static const borderDash = Color(0xFFE0C898);
  static const chipBg = Color(0xFFF0E8D8);
  static const chipBdr = Color(0xFFDDD0B8);
  static const heroDeco1 = Color(0x2EC9943A);
  static const heroDeco2 = Color(0x18C9943A);
  static const quizBtn = Color(0xFF2A1A0E);
  static const audioBtnA = Color(0xFFC9943A);
  static const audioBtnB = Color(0xFFE8B84B);
  static const formulaCardBg = Color(0xFFFAF6EE);
  static const formulaTagBg = Color(0xFF2A1A0E);
  static const formulaTagText = Color(0xFFE8B84B);
  static const skeletonBg = Color(0xFFEDE0C8);
  static const errorBg = Color(0xFFFFF0F0);
  static const errorBdr = Color(0xFFFFCCCC);
  static const errorText = Color(0xFFB94040);
}

// ─────────────────────────────────────────────────────────────
// LATEX PARSER HELPER
// Splits a string into alternating plain-text / LaTeX segments.
// Handles both \( ... \) and \[ ... \] delimiters.
// ─────────────────────────────────────────────────────────────
sealed class _Segment {}

class _TextSegment extends _Segment {
  final String text;
  _TextSegment(this.text);
}

class _LatexSegment extends _Segment {
  final String latex;
  final bool isDisplay; // true for \[ \]
  _LatexSegment(this.latex, {this.isDisplay = false});
}

List<_Segment> _parseSegments(String raw) {
  // Normalise escaped delimiters that come from JSON double-encoding
  final s = raw
      .replaceAll(r'\\(', r'\(')
      .replaceAll(r'\\)', r'\)')
      .replaceAll(r'\\[', r'\[')
      .replaceAll(r'\\]', r'\]');

  final segments = <_Segment>[];
  // Match \( ... \) for inline and \[ ... \] for display
  final re = RegExp(r'\\\((.+?)\\\)|\\\[(.+?)\\\]', dotAll: true);
  int cursor = 0;

  for (final m in re.allMatches(s)) {
    if (m.start > cursor) {
      segments.add(_TextSegment(s.substring(cursor, m.start)));
    }
    final isDisplay = m.group(2) != null;
    final latex = (m.group(1) ?? m.group(2))!.trim();
    segments.add(_LatexSegment(latex, isDisplay: isDisplay));
    cursor = m.end;
  }

  if (cursor < s.length) {
    segments.add(_TextSegment(s.substring(cursor)));
  }

  return segments;
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AIAnalysisScreen extends ConsumerStatefulWidget {
  final File? file;
  final String? displayName;

  const AIAnalysisScreen({super.key, this.file, this.displayName});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  String? _fileName;
  int _tab = 0; // 0=Summary 1=Rules 2=Analysis 3=Definitions

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      _fileName = widget.file!.path.split(RegExp(r'[\\\\/]+')).last;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(analysisViewModelProvider(_fileName!).notifier).loadAll(widget.file!);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null || !mounted) return;
    final file = File(picked.path!);
    setState(() {
      _fileName = picked.name;
      _tab = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analysisViewModelProvider(_fileName!).notifier).loadAll(file);
    });
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EDD8), Color(0xFFEDD9B8), Color(0xFFE8D0A8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _TopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: _fileName == null ? _buildEmpty() : _buildAnalysis(),
            ),
            _buildBottomBar(context),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _C.chipBg,
                shape: BoxShape.circle,
                border: Border.all(color: _C.borderDash, width: 1.5),
              ),
              child: const Icon(Icons.upload_file_rounded, size: 36, color: _C.goldDark),
            ),
            const SizedBox(height: 18),
            const Text('Upload a document to analyze',
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark)),
            const SizedBox(height: 6),
            const Text('PDF, DOC, DOCX, PNG, or JPG',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w400)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.quizBtn,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: _C.quizBtn.withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Pick a file',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ANALYSIS VIEW
  // ─────────────────────────────────────────────────────────
  Widget _buildAnalysis() {
    final state = ref.watch(analysisViewModelProvider(_fileName!));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _HeroCard(
            displayName: widget.displayName ?? _fileName ?? '',
            visualStatus: state.visualStatus,
            summaryStatus: state.summaryStatus,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            _StatTile(
              value: state.visualData?.graphsAnalyzed.toString() ?? '–',
              label: 'Graphs',
            ),
            const SizedBox(width: 8),
            _StatTile(
              value: state.rulesData?.ruleLines.length.toString() ?? '–',
              label: 'Rules',
            ),
            const SizedBox(width: 8),
            _StatTile(
              value: state.visualData != null ? '✓' : '–',
              label: 'Visuals',
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _TabBar(
            active: _tab,
            labels: const ['Summary', 'Rules', 'Analysis', 'Definitions'],
            icons: const [
              Icons.notes_rounded,
              Icons.rule_rounded,
              Icons.bar_chart_rounded,
              Icons.menu_book_rounded,
            ],
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _buildTabContent(state),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _SectionLabel('Topics Identified'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildTopicsChips(state),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: _AskAIStrip(onTap: () {
            Navigator.pushNamed(context, '/ai-chat', arguments: {
              'fileName': widget.displayName ?? _fileName ?? '',
            });
          }),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB ROUTER
  // ─────────────────────────────────────────────────────────
  Widget _buildTabContent(AnalysisState state) {
    switch (_tab) {
      case 0:
        return _buildSummaryTab(state);
      case 1:
        return _buildRulesTab(state);
      case 2:
        return _buildAnalysisTab(state);
      case 3:
        return _buildDefinitionsTab(state);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────
  // TAB 0 — SUMMARY
  // ─────────────────────────────────────────────────────────
  Widget _buildSummaryTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);
    return _ContentShell(
      label: 'AI Summary',
      child: switch (state.summaryStatus) {
        LoadStatus.idle || LoadStatus.loading => const _TextSkeleton(lines: 6),
        LoadStatus.failure => _ErrorRetry(
            message: state.summaryError ?? 'Failed to load summary',
            onRetry: vm.retrySummary,
          ),
        LoadStatus.success => _MarkdownText(text: state.summaryData!.summary),
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB 1 — RULES
  // ─────────────────────────────────────────────────────────
  Widget _buildRulesTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const _SectionLabel('Rules & Formulas'),
        const Spacer(),
        GestureDetector(
          onTap: vm.retryRules,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.chipBg,
              border: Border.all(color: _C.chipBdr),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, size: 11, color: _C.textMuted),
              const SizedBox(width: 4),
              const Text('Refresh',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      switch (state.rulesStatus) {
        LoadStatus.idle ||
        LoadStatus.loading =>
          Column(children: List.generate(3, (_) => const _RuleSkeleton())),
        LoadStatus.failure => _ErrorRetry(
            message: state.rulesError ?? 'Failed to load rules',
            onRetry: vm.retryRules,
          ),
        LoadStatus.success => state.rulesData!.ruleLines.isEmpty
            ? _EmptyState(
                icon: Icons.rule_rounded,
                message: 'No rules found in this document',
              )
            : Column(
                children: state.rulesData!.ruleLines
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RuleCard(index: e.key + 1, content: e.value),
                        ))
                    .toList(),
              ),
      },
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // TAB 2 — VISUAL ANALYSIS
  // ─────────────────────────────────────────────────────────
  Widget _buildAnalysisTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);
    return _ContentShell(
      label: 'Visual Analysis',
      child: switch (state.visualStatus) {
        LoadStatus.idle || LoadStatus.loading => const _TextSkeleton(lines: 5),
        LoadStatus.failure => _ErrorRetry(
            message: state.visualError ?? 'Failed to analyze visuals',
            onRetry: () => vm.retryAll(widget.file!),
          ),
        LoadStatus.success => _VisualAnalysisBody(data: state.visualData!),
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB 3 — DEFINITIONS
  // ─────────────────────────────────────────────────────────
  Widget _buildDefinitionsTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const _SectionLabel('Definitions'),
        const Spacer(),
        GestureDetector(
          onTap: vm.retryDefinitions,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.chipBg,
              border: Border.all(color: _C.chipBdr),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, size: 11, color: _C.textMuted),
              const SizedBox(width: 4),
              const Text('Refresh',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      switch (state.definitionStatus) {
        LoadStatus.idle || LoadStatus.loading => const _TextSkeleton(lines: 6),
        LoadStatus.failure => _ErrorRetry(
            message: state.definitionError ?? 'Failed to load definitions',
            onRetry: vm.retryDefinitions,
          ),
        LoadStatus.success => state.definitionsData!.markdownContent.trim().isEmpty
            ? _EmptyState(
                icon: Icons.menu_book_rounded,
                message: 'No definitions found in this document',
              )
            : _ContentShell(
                label: '',
                child: _MarkdownText(text: state.definitionsData!.markdownContent),
              ),
      },
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // TOPICS CHIPS
  // ─────────────────────────────────────────────────────────
  Widget _buildTopicsChips(AnalysisState state) {
    final topics = state.visualStatus == LoadStatus.success
        ? _extractTopics(state.visualData!.correctedText)
        : <String>['SN1 Mechanism', 'SN2 Mechanism', 'Carbocations', 'Stereochemistry'];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: topics.map((t) => _Chip(label: t)).toList(),
    );
  }

  List<String> _extractTopics(String text) {
    final headings = RegExp(r'#{1,3} (.+)').allMatches(text);
    final topics = headings.map((m) => m.group(1)!.trim()).take(6).toList();
    return topics.isEmpty
        ? ['Energy Bands', 'Insulators', 'Forbidden Gap', 'Dielectric Strength']
        : topics;
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final summaryData =
        _fileName != null ? ref.watch(analysisViewModelProvider(_fileName!)).summaryData : null;
    final audioReady = (summaryData?.audioUrl ?? '').isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      decoration: BoxDecoration(
        color: _C.cardBg,
        border: Border(top: BorderSide(color: _C.border)),
        boxShadow: [
          BoxShadow(
              color: _C.textDark.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/quiz_screen'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.quizBtn,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: _C.quizBtn.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Generate Quiz',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('✦', style: TextStyle(fontSize: 9, color: Color(0x88FFFFFF))),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (!audioReady) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio is still being generated…')),
              );
              return;
            }
            Navigator.pushNamed(
              context,
              '/audio_screen',
              arguments: {
                'audioUrl': summaryData!.audioUrl,
                'summary': summaryData.summary,
                'displayName': widget.displayName ?? _fileName ?? summaryData.filename,
              },
            );
          },
          child: Opacity(
            opacity: audioReady ? 1 : 0.5,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.audioBtnA, _C.audioBtnB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: _C.goldDark.withOpacity(0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Center(
                  child: Icon(Icons.headphones_rounded, size: 20, color: Colors.white)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RULE CARD — parses plain text + LaTeX segments
// ─────────────────────────────────────────────────────────────
class _RuleCard extends StatelessWidget {
  final int index;
  final String content;
  const _RuleCard({required this.index, required this.content});

  @override
  Widget build(BuildContext context) {
    final segments = _parseSegments(content);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _C.formulaCardBg,
        border: Border.all(color: _C.border, width: 1.2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: _C.textDark.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Index badge
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(color: _C.formulaTagBg, shape: BoxShape.circle),
          child: Center(
            child: Text('$index',
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _C.formulaTagText)),
          ),
        ),
        const SizedBox(width: 10),

        // Content — mixed text + LaTeX
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 6,
            children: segments.map((seg) {
              if (seg is _TextSegment) {
                final trimmed = seg.text.trim();
                if (trimmed.isEmpty) return const SizedBox.shrink();
                return Text(
                  trimmed,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: _C.textBody,
                      height: 1.6,
                      fontWeight: FontWeight.w400),
                );
              }

              final latex = seg as _LatexSegment;

              // Display math — full-width centered block
              if (latex.isDisplay) {
                return SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Math.tex(
                      latex.latex,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 15, color: _C.textDark),
                      onErrorFallback: (e) => Text(
                        latex.latex,
                        style: const TextStyle(
                            fontFamily: 'DM Mono', fontSize: 12, color: _C.textMuted),
                      ),
                    ),
                  ),
                );
              }

              // Inline math — dark pill background
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.formulaTagBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Math.tex(
                  latex.latex,
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(fontSize: 13, color: _C.goldLight),
                  onErrorFallback: (e) => Text(
                    latex.latex,
                    style:
                        const TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: _C.goldLight),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// RULE SKELETON
// ─────────────────────────────────────────────────────────────
class _RuleSkeleton extends StatefulWidget {
  const _RuleSkeleton();
  @override
  State<_RuleSkeleton> createState() => _RuleSkeletonState();
}

class _RuleSkeletonState extends State<_RuleSkeleton> with SingleTickerProviderStateMixin {
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
          opacity: 0.4 + _c.value * 0.4,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: _C.formulaCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
            ),
            child: Row(children: [
              Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: _C.skeletonBg, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                      width: double.infinity,
                      height: 11,
                      decoration: BoxDecoration(
                          color: _C.skeletonBg, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.55,
                      height: 11,
                      decoration: BoxDecoration(
                          color: _C.skeletonBg.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4))),
                ]),
              ),
            ]),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(icon, size: 28, color: _C.textMuted.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: _C.textMuted,
                  fontWeight: FontWeight.w400)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// VISUAL ANALYSIS BODY
// ─────────────────────────────────────────────────────────────
class _VisualAnalysisBody extends StatelessWidget {
  final VisualAnalysisModel data;
  const _VisualAnalysisBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (data.rawText.isNotEmpty) ...[
        const _SectionLabel('Extracted Text'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.formulaCardBg,
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(data.rawText,
              style: const TextStyle(
                  fontFamily: 'DM Mono', fontSize: 11, color: _C.textBody, height: 1.6)),
        ),
        const SizedBox(height: 16),
      ],
      if (data.graphs.isNotEmpty) ...[
        _SectionLabel('Graphs Analysed (${data.graphs.length})'),
        const SizedBox(height: 8),
        ...data.graphs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GraphCard(index: e.key + 1, graph: e.value),
            )),
        const SizedBox(height: 8),
      ],
      const _SectionLabel('Full Analysis'),
      const SizedBox(height: 8),
      _MarkdownText(text: data.correctedText),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// GRAPH CARD
// ─────────────────────────────────────────────────────────────
class _GraphCard extends StatefulWidget {
  final int index;
  final GraphAnalysis graph;
  const _GraphCard({required this.index, required this.graph});
  @override
  State<_GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<_GraphCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _C.cardBg,
          border: Border.all(color: _C.border),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration:
                    BoxDecoration(color: _C.formulaTagBg, borderRadius: BorderRadius.circular(6)),
                child: Text('Graph ${widget.index}',
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _C.formulaTagText,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.graph.image,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: _C.textMuted,
                        overflow: TextOverflow.ellipsis)),
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _C.textMuted),
              ),
            ]),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(widget.graph.analysis,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: _C.textBody,
                            height: 1.6,
                            fontWeight: FontWeight.w300)),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: Text(widget.graph.analysis,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: _C.textMuted,
                            height: 1.5,
                            fontWeight: FontWeight.w300)),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MARKDOWN TEXT
// ─────────────────────────────────────────────────────────────
class _MarkdownText extends StatelessWidget {
  final String text;
  const _MarkdownText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(line.substring(2),
                style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark)),
          );
        }
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 3),
            child: Text(line.substring(3),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textDark)),
          );
        }
        if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(line.substring(4),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textBody)),
          );
        }
        if (line.trim().isEmpty) return const SizedBox(height: 4);
        final body = line.replaceFirst(RegExp(r'^[-•]\s+'), '');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Text(body,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  color: _C.textBody,
                  height: 1.65,
                  fontWeight: FontWeight.w300)),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTENT SHELL
// ─────────────────────────────────────────────────────────────
class _ContentShell extends StatelessWidget {
  final String label;
  final Widget child;
  const _ContentShell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.isNotEmpty) ...[
            _SectionLabel(label),
            const SizedBox(height: 10),
          ],
          child,
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// ERROR + RETRY
// ─────────────────────────────────────────────────────────────
class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.errorBg,
          border: Border.all(color: _C.errorBdr),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.error_outline_rounded, size: 14, color: _C.errorText),
            const SizedBox(width: 6),
            const Text('Failed to load',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.errorText)),
          ]),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  color: _C.errorText,
                  fontWeight: FontWeight.w300)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: _C.textDark, borderRadius: BorderRadius.circular(8)),
              child: const Text('Retry',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// TEXT SKELETON
// ─────────────────────────────────────────────────────────────
class _TextSkeleton extends StatefulWidget {
  final int lines;
  const _TextSkeleton({required this.lines});
  @override
  State<_TextSkeleton> createState() => _TextSkeletonState();
}

class _TextSkeletonState extends State<_TextSkeleton> with SingleTickerProviderStateMixin {
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
          opacity: 0.4 + _c.value * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.lines, (i) {
              final widths = [0.9, 0.75, 0.88, 0.6, 0.82, 0.7];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 11,
                width: MediaQuery.of(context).size.width * widths[i % widths.length],
                decoration:
                    BoxDecoration(color: _C.skeletonBg, borderRadius: BorderRadius.circular(4)),
              );
            }),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          _IcoBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const Expanded(
            child: Center(
              child: Text('AI Analysis',
                  style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark)),
            ),
          ),
          _IcoBtn(icon: Icons.upload_rounded, onTap: () {}),
        ]),
      );
}

class _IcoBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IcoBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _C.cardBg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 14, color: _C.textDark),
        ),
      );
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final bool filled;
  const _HeroBadge({required this.label, required this.filled});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(filled ? 0.14 : 0.08),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
                color: filled ? _C.goldLight : Colors.white70)),
      );
}

class _HeroCard extends StatelessWidget {
  final String displayName;
  final LoadStatus visualStatus;
  final LoadStatus summaryStatus;
  const _HeroCard({
    required this.displayName,
    required this.visualStatus,
    required this.summaryStatus,
  });

  String get _statusLabel {
    if (visualStatus == LoadStatus.loading || summaryStatus == LoadStatus.loading)
      return 'Analysing…';
    if (visualStatus == LoadStatus.failure || summaryStatus == LoadStatus.failure)
      return 'Partial Results';
    if (visualStatus == LoadStatus.success && summaryStatus == LoadStatus.success)
      return 'Analysis Complete';
    return 'Processing…';
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _C.heroCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: _C.heroCard.withOpacity(0.50), blurRadius: 36, offset: const Offset(0, 12))
          ],
        ),
        child: Stack(clipBehavior: Clip.hardEdge, children: [
          Positioned(
              top: -30,
              right: -30,
              child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.heroDeco1))),
          Positioned(
              bottom: -20,
              right: 20,
              child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.heroDeco2))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration:
                      BoxDecoration(color: _C.goldDark, borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.insert_drive_file_rounded, size: 11, color: Colors.white),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9.5,
                          color: _C.textMuted,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(_statusLabel,
                  style: const TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.4,
                      height: 1.2)),
              const SizedBox(height: 12),
              Row(children: [
                _HeroBadge(
                  label: visualStatus == LoadStatus.loading
                      ? '⟳ Analyzing visuals'
                      : visualStatus == LoadStatus.success
                          ? '✦ Visuals ready'
                          : '✕ Visual error',
                  filled: visualStatus == LoadStatus.success,
                ),
                const SizedBox(width: 8),
                _HeroBadge(
                  label: summaryStatus == LoadStatus.loading
                      ? '⟳ Summarizing'
                      : summaryStatus == LoadStatus.success
                          ? '✦ Summary ready'
                          : '✕ Summary error',
                  filled: summaryStatus == LoadStatus.success,
                ),
              ]),
            ]),
          ),
        ]),
      );
}

class _TabBar extends StatelessWidget {
  final int active;
  final List<String> labels;
  final List<IconData> icons;
  final void Function(int) onTap;
  const _TabBar(
      {required this.active, required this.labels, required this.icons, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: List.generate(
            labels.length,
            (i) => Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: active == i ? _C.textDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i], size: 13, color: active == i ? _C.goldLight : _C.textMuted),
                      const SizedBox(height: 2),
                      Text(labels[i],
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: active == i ? Colors.white : _C.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _C.cardBg,
            border: Border.all(color: _C.border),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: _C.textDark.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 8.5,
                    color: _C.textMuted,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: _C.textMuted,
          letterSpacing: 1.1));
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: _C.chipBg,
          border: Border.all(color: _C.chipBdr),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                color: _C.textDark,
                fontWeight: FontWeight.w400)),
      );
}

class _AskAIStrip extends StatelessWidget {
  final VoidCallback onTap;
  const _AskAIStrip({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _C.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.borderDash.withOpacity(0.80), width: 1.5),
          ),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
              child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, size: 16, color: _C.goldLight)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ask AI about this document',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark)),
                SizedBox(height: 1),
                Text('Tap to start a conversation',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        color: _C.textMuted,
                        fontWeight: FontWeight.w300)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: _C.goldDark),
          ]),
        ),
      );
}

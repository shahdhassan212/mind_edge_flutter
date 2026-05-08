import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/model/analysis_models.dart';
import '../features/analysis/viewmodel/analysis_viewmodel.dart';

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
  static const planBtn = Color(0xFF2E2840);
  static const audioBtnA = Color(0xFFC9943A);
  static const audioBtnB = Color(0xFFE8B84B);
  static const bubbleUser = Color(0xFF2A1A0E);
  static const bubbleAI = Color(0xFFFEFCF7);
  static const inputBg = Color(0xFFF4EDE0);
  static const formulaCardBg = Color(0xFFFAF6EE);
  static const formulaTagBg = Color(0xFF2A1A0E);
  static const formulaTagText = Color(0xFFE8B84B);
  static const skeletonBg = Color(0xFFEDE0C8);
  static const errorBg = Color(0xFFFFF0F0);
  static const errorBdr = Color(0xFFFFCCCC);
  static const errorText = Color(0xFFB94040);
}

// ─────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────
class AIAnalysisScreen extends ConsumerStatefulWidget {
  /// The file sent to analyze-visuals (needed for multipart upload).
  /// Optional — when null, the screen shows an empty state with an
  /// upload button so the user can pick a file from inside the screen.
  final File? file;

  /// Display name shown in the hero card
  final String? displayName;

  const AIAnalysisScreen({
    super.key,
    this.file,
    this.displayName,
  });

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  // Mutable so we can swap files via in-screen upload.
  File? _file;
  String? _displayName;
  String? _fileName;

  // UI state
  int _tab = 0; // 0=Summary 1=Formulas 2=Key Terms
  bool _chatOpen = false;
  bool _aiTyping = false;

  final List<_Msg> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      _setFile(widget.file!, widget.displayName ?? widget.file!.path.split(RegExp(r'[\\/]+')).last);
    }
  }

  void _setFile(File file, String displayName) {
    _file = file;
    _displayName = displayName;
    _fileName = file.path.split(RegExp(r'[\\/]+')).last;

    // Kick off all endpoints once a file is loaded.
    // analyze-visuals → process-audio is sequential (summary needs document_name),
    // formulas runs independently in parallel.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _fileName == null) return;
      final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);
      vm.loadVisualAnalysisThenSummary(file);
      vm.loadFormulas();
    });
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
    setState(() {
      _tab = 0;
      _msgs.clear();
      _setFile(File(picked.path!), picked.name);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }


  void _scrollDown() => Future.delayed(const Duration(milliseconds: 80), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
        }
      });

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
            _TopBar(
              onBack: () {
                if (_chatOpen)
                  setState(() => _chatOpen = false);
                else
                  Navigator.pop(context);
              },
              onUpload: _pickFile,
            ),
            Expanded(
              child: _file == null
                  ? _EmptyUpload(onPick: _pickFile)
                  : (_chatOpen ? _buildChat() : _buildAnalysis()),
            ),
            _buildBottomBar(context),
          ]),
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
            displayName: _displayName!,
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
              value: state.formulas.length.toString(),
              label: 'Formulas',
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
            labels: const ['Summary', 'Formulas', 'Analysis'],
            icons: const [
              Icons.notes_rounded,
              Icons.functions_rounded,
              Icons.bar_chart_rounded,
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
            setState(() {
              _chatOpen = true;
              if (_msgs.isEmpty) {
                _msgs.add(
                    const _Msg(text: 'مرحباً! اسألني أي سؤال عن محتوى الملف 🧪', isUser: false));
              }
            });
          }),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB CONTENT ROUTER
  // ─────────────────────────────────────────────────────────
  Widget _buildTabContent(AnalysisState state) {
    switch (_tab) {
      case 0:
        return _buildSummaryTab(state);
      case 1:
        return _buildFormulaSheet(state);
      case 2:
        return _buildAnalysisTab(state);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────
  // TAB 0 — SUMMARY (process-audio)
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
  // TAB 2 — VISUAL ANALYSIS (analyze-visuals)
  // ─────────────────────────────────────────────────────────
  Widget _buildAnalysisTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);

    return _ContentShell(
      label: 'Visual Analysis',
      child: switch (state.visualStatus) {
        LoadStatus.idle || LoadStatus.loading => const _TextSkeleton(lines: 5),
        LoadStatus.failure => _ErrorRetry(
            message: state.visualError ?? 'Failed to analyze visuals',
            onRetry: () => vm.retryAll(_file!),
          ),
        LoadStatus.success => _VisualAnalysisBody(data: state.visualData!),
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB 1 — FORMULA SHEET
  // ─────────────────────────────────────────────────────────
  Widget _buildFormulaSheet(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName!).notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const _SectionLabel('Formula Sheet'),
        const Spacer(),
        GestureDetector(
          onTap: vm.loadFormulas,
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

      // Category filter pills
      if (state.categories.isNotEmpty && state.formulaStatus == LoadStatus.success) ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterPill(
              label: 'All',
              active: state.formulaFilter == null,
              onTap: () => vm.setFormulaFilter(null),
            ),
            const SizedBox(width: 6),
            ...state.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterPill(
                    label: cat,
                    active: state.formulaFilter == cat,
                    onTap: () => vm.setFormulaFilter(state.formulaFilter == cat ? null : cat),
                  ),
                )),
          ]),
        ),
        const SizedBox(height: 12),
      ],

      if (state.formulaStatus == LoadStatus.loading)
        Column(children: List.generate(3, (_) => const _FormulaSkeleton()))
      else if (state.filteredFormulas.isEmpty)
        _EmptyFormulas()
      else
        Column(
          children: state.filteredFormulas
              .map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FormulaCard(
                      item: f,
                      onAskAI: () {
                        setState(() {
                          _chatOpen = true;
                          _msgs.add(_Msg(
                              text: 'Explain the formula: ${f.label} — ${f.expression}',
                              isUser: true));
                          _aiTyping = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1200), () {
                          if (!mounted) return;
                          setState(() {
                            _aiTyping = false;
                            _msgs.add(_Msg(
                                text: '${f.label}: ${f.description} — ${f.variables.join(", ")}.',
                                isUser: false));
                          });
                          _scrollDown();
                        });
                      },
                    ),
                  ))
              .toList(),
        ),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // TOPICS CHIPS — dynamic from correctedText keywords
  // ─────────────────────────────────────────────────────────
  Widget _buildTopicsChips(AnalysisState state) {
    final topics = state.visualStatus == LoadStatus.success
        ? _extractTopics(state.visualData!.correctedText)
        : <String>['', '','',''];

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: topics.map((t) => _Chip(label: t)).toList(),
    );
  }

  /// Simple keyword extractor — pulls bold markdown headings as topic chips
  List<String> _extractTopics(String text) {
    final headings = RegExp(r'#{1,3} (.+)').allMatches(text);
    final topics = headings.map((m) => m.group(1)!.trim()).take(6).toList();
    return topics.isEmpty
        ? ['', '', '', '']
        : topics;
  }

  // ─────────────────────────────────────────────────────────
  // CHAT VIEW
  // ─────────────────────────────────────────────────────────
  Widget _buildChat() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: _C.cardBg,
          border: Border(bottom: BorderSide(color: _C.border)),
        ),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _chatOpen = false),
            child: const Row(children: [
              Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: _C.textMuted),
              SizedBox(width: 4),
              Text('Back',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: _C.textMuted,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: 12),
          const Text('Ask AI',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark)),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          itemCount: _msgs.length + (_aiTyping ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (_aiTyping && i == _msgs.length) return const _TypingBubble();
            return _ChatBubble(msg: _msgs[i]);
          },
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: _C.cardBg,
          border: Border(top: BorderSide(color: _C.border)),
        ),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _C.inputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textDark),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ask about this document...',
                  hintStyle: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _C.textHint),
                ),
               // onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
          //  onTap: _send,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: _C.bubbleUser, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
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
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/study_plan_screen'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _C.planBtn,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: _C.planBtn.withOpacity(0.40),
                      blurRadius: 18,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Add to Study Plan',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('✦', style: TextStyle(fontSize: 9, color: Color(0x88FFFFFF))),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/audio_screen'),
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
            child:
                const Center(child: Icon(Icons.headphones_rounded, size: 20, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
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
      // Raw extracted text
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
          child: Text(
            data.rawText,
            style: const TextStyle(
                fontFamily: 'DM Mono', fontSize: 11, color: _C.textBody, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Graph analyses
      if (data.graphs.isNotEmpty) ...[
        _SectionLabel('Graphs Analysed (${data.graphs.length})'),
        const SizedBox(height: 8),
        ...data.graphs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GraphCard(index: e.key + 1, graph: e.value),
            )),
        const SizedBox(height: 8),
      ],

      // Corrected / full markdown
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
                decoration: BoxDecoration(
                  color: _C.formulaTagBg,
                  borderRadius: BorderRadius.circular(6),
                ),
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
                child: Text(
                  widget.graph.image,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _C.textMuted,
                      overflow: TextOverflow.ellipsis),
                ),
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
                    child: Text(
                      widget.graph.analysis,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: _C.textBody,
                          height: 1.6,
                          fontWeight: FontWeight.w300),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: Text(
                      widget.graph.analysis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: _C.textMuted,
                          height: 1.5,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MARKDOWN TEXT — renders ## headings + **bold** simply
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
        // Strip leading "- " or "N. "
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
          _SectionLabel(label),
          const SizedBox(height: 10),
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
              decoration: BoxDecoration(
                color: _C.textDark,
                borderRadius: BorderRadius.circular(8),
              ),
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
// TEXT SKELETON (summary / analysis loading)
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
// EMPTY FORMULAS
// ─────────────────────────────────────────────────────────────
class _EmptyFormulas extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Icon(Icons.functions_rounded, size: 28, color: _C.textMuted.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text('No formulas found',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: _C.textMuted,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text('Waiting for AI extraction…',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: _C.textMuted.withOpacity(0.6),
                  fontWeight: FontWeight.w300)),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// HERO CARD — shows live status badges
// ─────────────────────────────────────────────────────────────
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
                  child: Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9.5,
                        color: _C.textMuted,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600),
                  ),
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

// ─────────────────────────────────────────────────────────────
// TAB BAR WITH ICONS
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// FORMULA CARD (unchanged logic, kept inline)
// ─────────────────────────────────────────────────────────────
class _FormulaCard extends StatefulWidget {
  final FormulaItem item;
  final VoidCallback onAskAI;
  const _FormulaCard({required this.item, required this.onAskAI});
  @override
  State<_FormulaCard> createState() => _FormulaCardState();
}

class _FormulaCardState extends State<_FormulaCard> {
  bool _expanded = false;
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.item.expression));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.item;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _C.formulaCardBg,
          border: Border.all(color: _C.border, width: 1.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _C.textDark.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration:
                    BoxDecoration(color: _C.formulaTagBg, borderRadius: BorderRadius.circular(6)),
                child: Text(f.category,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _C.formulaTagText,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(f.label,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _C.textDark)),
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _C.textMuted),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration:
                  BoxDecoration(color: _C.textDark, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(
                  child: Text(f.expression,
                      style: const TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _C.goldLight,
                          letterSpacing: 0.5,
                          height: 1.3)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _copy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          _copied ? _C.goldDark.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                          color: _copied
                              ? _C.goldDark.withOpacity(0.5)
                              : Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _copied ? _C.goldLight : Colors.white54),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(f.description,
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: _C.textMuted,
                    fontWeight: FontWeight.w300,
                    height: 1.5)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const _SectionLabel('Variables'),
                      const SizedBox(height: 6),
                      ...f.variables.map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                      color: _C.goldDark, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(v,
                                    style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11.5,
                                        color: _C.textBody,
                                        fontWeight: FontWeight.w300,
                                        height: 1.5)),
                              ),
                            ]),
                          )),
                    ]),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 13),
            child: Row(children: [
              GestureDetector(
                onTap: widget.onAskAI,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.goldDark.withOpacity(0.10),
                    border: Border.all(color: _C.goldDark.withOpacity(0.25)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_awesome_rounded, size: 11, color: _C.goldDark),
                    const SizedBox(width: 5),
                    const Text('Ask AI',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _C.goldDark)),
                  ]),
                ),
              ),
              const Spacer(),
              Text(
                _expanded ? 'Hide details' : 'Show variables',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: _C.textMuted.withOpacity(0.7),
                    fontWeight: FontWeight.w400),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FORMULA SKELETON
// ─────────────────────────────────────────────────────────────
class _FormulaSkeleton extends StatefulWidget {
  const _FormulaSkeleton();
  @override
  State<_FormulaSkeleton> createState() => _FormulaSkeletonState();
}

class _FormulaSkeletonState extends State<_FormulaSkeleton> with SingleTickerProviderStateMixin {
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.formulaCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                        color: _C.skeletonBg, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                        color: _C.skeletonBg, borderRadius: BorderRadius.circular(4))),
              ]),
              const SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  height: 44,
                  decoration:
                      BoxDecoration(color: _C.skeletonBg, borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 8),
              Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _C.skeletonBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4))),
            ]),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// FILTER PILL
// ─────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? _C.textDark : _C.chipBg,
            border: Border.all(color: active ? _C.textDark : _C.chipBdr),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : _C.textDark)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onUpload;
  const _TopBar({required this.onBack, required this.onUpload});
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
          _IcoBtn(icon: Icons.upload_rounded, onTap: onUpload),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────
// EMPTY STATE — shown when the screen opens with no file
// ─────────────────────────────────────────────────────────────
class _EmptyUpload extends StatelessWidget {
  final VoidCallback onPick;
  const _EmptyUpload({required this.onPick});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: _C.textDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 34, color: _C.goldLight),
            ),
            const SizedBox(height: 18),
            const Text('Upload a file to analyze',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark)),
            const SizedBox(height: 6),
            const Text(
              'Pick a PDF, document, or image and AI will summarise it, extract formulas, and analyse visuals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: _C.textMuted,
                  height: 1.55,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.audioBtnA, _C.audioBtnB],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                        color: _C.goldDark.withOpacity(0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.upload_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Upload File',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
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

class _Msg {
  final String text;
  final bool isUser;
  const _Msg({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 7),
                decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
                child: const Center(
                    child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isUser ? _C.bubbleUser : _C.bubbleAI,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                  ),
                  border: msg.isUser ? null : Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                        color: _C.textDark.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(msg.text,
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: msg.isUser ? Colors.white : _C.textDark,
                        height: 1.55,
                        fontWeight: FontWeight.w300)),
              ),
            ),
            if (msg.isUser) const SizedBox(width: 4),
          ],
        ),
      );
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 7),
            decoration: const BoxDecoration(color: _C.textDark, shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 13, color: _C.goldLight)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: _C.bubbleAI,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _C.border),
            ),
            child: const Text('typing...',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: _C.textMuted,
                    fontStyle: FontStyle.italic)),
          ),
        ]),
      );
}

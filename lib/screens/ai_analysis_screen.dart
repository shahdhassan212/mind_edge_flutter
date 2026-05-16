// screens/ai_analysis_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../features/analysis/model/analysis_models.dart';
import '../features/analysis/providers/analysis_providersl.dart';
import '../theme/design_tokens.dart';
import '../widgets/ai_analysis_widgets.dart';
import '../widgets/common_widgets.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  final File file;
  final String? displayName;
  const AIAnalysisScreen({super.key, required this.file, this.displayName});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  late String _fileName;
  int _tab = 0;

  Future<void> _downloadPdf() async {
    final state = ref.read(analysisViewModelProvider(_fileName));
    final title = widget.displayName ?? _fileName;

    // Check if we have at least summary data
    if (state.summaryData == null && state.rulesData == null && state.definitionsData == null) {
      AppSnackBar.show(context, 'Analysis not ready yet', isError: true);
      return;
    }

    try {
      final file = await ref.read(analysisRepoProvider).downloadSummaryPdf(
            title: title,
            state: state,
          );
      if (!mounted) return;
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to download PDF', isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _fileName = widget.file.path.split(RegExp(r'[\\\\/]+')).last;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analysisViewModelProvider(_fileName).notifier).loadAll(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.55, 1.0],
            colors: [
              Color(0xFFF7EDD8),
              Color(0xFFEDD9B8),
              Color(0xFFE8D0A8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            AiTopBar(
              onBack: () => Navigator.pop(context),
              onDownload: _downloadPdf,
            ),
            Expanded(child: _buildAnalysis()),
            _buildBottomBar(context),
          ]),
        ),
      ),
    );
  }

  // ── Analysis view ─────────────────────────────────────────────
  Widget _buildAnalysis() {
    final state = ref.watch(analysisViewModelProvider(_fileName));
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: AiHeroCard(
            displayName: widget.displayName ?? _fileName,
            visualStatus: state.visualStatus,
            summaryStatus: state.summaryStatus,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            AiStatTile(value: state.visualData?.graphsAnalyzed.toString() ?? '–', label: 'Graphs'),
            const SizedBox(width: 8),
            AiStatTile(
                value: state.rulesData?.parsedRules.length.toString() ?? '–', label: 'Rules'),
            const SizedBox(width: 8),
            AiStatTile(value: state.visualData != null ? '✓' : '–', label: 'Visuals'),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AiTabBar(
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
          child: AiSectionLabel('Topics Identified'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _buildTopicsChips(state),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: AiAskStrip(
            onTap: () => Navigator.pushNamed(context, '/ai-chat', arguments: {
              'fileName': widget.displayName ?? _fileName,
              'sessionId': state.visualData?.sessionId,
            }),
          ),
        ),
      ]),
    );
  }

  // ── Tab router ────────────────────────────────────────────────
  Widget _buildTabContent(AnalysisState state) => switch (_tab) {
        0 => _buildSummaryTab(state),
        1 => _buildRulesTab(state),
        2 => _buildAnalysisTab(state),
        3 => _buildDefinitionsTab(state),
        _ => const SizedBox.shrink(),
      };

  // ── Tab 0 — Summary ───────────────────────────────────────────
  Widget _buildSummaryTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName).notifier);
    return AiContentShell(
      label: 'AI Summary',
      child: switch (state.summaryStatus) {
        LoadStatus.idle || LoadStatus.loading => const AiTextSkeleton(lines: 6),
        LoadStatus.failure => AiErrorRetry(
            message: state.summaryError ?? 'Failed to load summary', onRetry: vm.retrySummary),
        LoadStatus.success => AiMarkdownText(text: state.summaryData!.summary),
      },
    );
  }

  // ── Tab 1 — Rules ─────────────────────────────────────────────
  Widget _buildRulesTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const AiSectionLabel('Rules & Formulas'),
          const Spacer(),
          AiRefreshBtn(onTap: vm.retryRules),
        ]),
        const SizedBox(height: 10),
        switch (state.rulesStatus) {
          LoadStatus.idle ||
          LoadStatus.loading =>
            Column(children: List.generate(3, (_) => const AiRuleSkeleton())),
          LoadStatus.failure => AiErrorRetry(
              message: state.rulesError ?? 'Failed to load rules', onRetry: vm.retryRules),
          LoadStatus.success => () {
              final parsed = state.rulesData!.parsedRules;
              if (parsed.isEmpty) {
                // Fallback to markdown if parser got nothing
                return state.rulesData!.rawRules.trim().isEmpty
                    ? AiEmptyState(
                        icon: Icons.rule_rounded, message: 'No rules found in this document')
                    : AiContentShell(
                        label: '',
                        child: AiMarkdownText(text: state.rulesData!.rawRules),
                      );
              }
              return Column(
                children: parsed
                    .asMap()
                    .entries
                    .map((e) => AiParsedRuleCard(
                          rule: e.value,
                          index: e.key + 1,
                        ))
                    .toList(),
              );
            }(),
        },
      ],
    );
  }

  // ── Tab 2 — Visual Analysis ───────────────────────────────────
  Widget _buildAnalysisTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName).notifier);
    return AiContentShell(
      label: 'Visual Analysis',
      child: switch (state.visualStatus) {
        LoadStatus.idle || LoadStatus.loading => const AiTextSkeleton(lines: 5),
        LoadStatus.failure => AiErrorRetry(
            message: state.visualError ?? 'Failed to analyze visuals',
            onRetry: () => vm.retryAll(widget.file)),
        LoadStatus.success => _VisualAnalysisBody(data: state.visualData!),
      },
    );
  }

  // ── Tab 3 — Definitions ───────────────────────────────────────
  Widget _buildDefinitionsTab(AnalysisState state) {
    final vm = ref.read(analysisViewModelProvider(_fileName).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const AiSectionLabel('Definitions'),
          const Spacer(),
          AiRefreshBtn(onTap: vm.retryDefinitions),
        ]),
        const SizedBox(height: 10),
        switch (state.definitionStatus) {
          LoadStatus.idle || LoadStatus.loading => const AiTextSkeleton(lines: 6),
          LoadStatus.failure => AiErrorRetry(
              message: state.definitionError ?? 'Failed to load definitions',
              onRetry: vm.retryDefinitions),
          LoadStatus.success => () {
              final parsed = state.definitionsData!.parsedDefinitions;
              if (parsed.isEmpty) {
                // Fallback to markdown
                return state.definitionsData!.markdownContent.trim().isEmpty
                    ? AiEmptyState(
                        icon: Icons.menu_book_rounded,
                        message: 'No definitions found in this document')
                    : AiContentShell(
                        label: '',
                        child: AiMarkdownText(text: state.definitionsData!.markdownContent));
              }
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.aiCardBg,
                  border: Border.all(color: AppColors.aiBorder),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.aiTextDark.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AiSectionLabel('Key Terms'),
                    const SizedBox(height: 12),
                    ...parsed
                        .asMap()
                        .entries
                        .map((e) => AiDefinitionRow(def: e.value, index: e.key)),
                  ],
                ),
              );
            }(),
        },
      ],
    );
  }

  // ── Topics chips ──────────────────────────────────────────────
  Widget _buildTopicsChips(AnalysisState state) {
    final topics = state.visualStatus == LoadStatus.success
        ? _extractTopics(state.visualData!.correctedText)
        : const ['on the way', 'let us crush it today', 'we can do it', 'keep going'];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: topics.map((t) => AiChip(label: t)).toList(),
    );
  }

  List<String> _extractTopics(String text) {
    final topics =
        RegExp(r'#{1,3} (.+)').allMatches(text).map((m) => m.group(1)!.trim()).take(6).toList();
    return topics.isEmpty ? ['', '', '', ''] : topics;
  }

  // ── Bottom bar ────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final analysisState = ref.watch(analysisViewModelProvider(_fileName));
    final summaryData = analysisState.summaryData;
    final audioReady = (summaryData?.audioUrl ?? '').isNotEmpty;
    final serverFilename = analysisState.visualData?.documentName ?? _fileName;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      decoration: BoxDecoration(
        color: AppColors.aiCardBg,
        border: Border(top: BorderSide(color: AppColors.aiBorder)),
        boxShadow: [
          BoxShadow(
              color: AppColors.aiTextDark.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(children: [
        // ── Generate Quiz ──────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/quiz',
              arguments: {
                'filename': serverFilename,
                'numQuestions': 10,
              },
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.aiTextDark,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.aiTextDark.withOpacity(0.30),
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

        // ── Study Plan ─────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/study-plan',
              arguments: {'filename': serverFilename},
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.aiCardBg,
                border: Border.all(color: AppColors.aiBorder, width: 1.5),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.aiTextDark.withOpacity(0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Study Plan',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.aiTextDark)),
                Text('✦', style: TextStyle(fontSize: 9, color: AppColors.aiGoldDark)),
              ]),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // ── Audio ──────────────────────────────────
        GestureDetector(
          onTap: () {
            if (!audioReady) {
              AppSnackBar.show(context, 'Audio is still being generated…', isError: false);
              return;
            }
            Navigator.pushNamed(context, '/audio_screen', arguments: {
              'audioUrl': summaryData!.audioUrl,
              'summary': summaryData.summary,
              'displayName': widget.displayName ?? _fileName,
            });
          },
          child: Opacity(
            opacity: audioReady ? 1 : 0.5,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.aiGoldDark, AppColors.aiGoldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.aiGoldDark.withOpacity(0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Center(
                child: Icon(Icons.headphones_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Visual analysis body ──────────────────────────────────────
class _VisualAnalysisBody extends StatelessWidget {
  final VisualAnalysisModel data;
  const _VisualAnalysisBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (data.rawText.isNotEmpty) ...[
        const AiSectionLabel('Extracted Text'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.aiFormulaCardBg,
            border: Border.all(color: AppColors.aiBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(data.rawText,
              style: const TextStyle(
                  fontFamily: 'DM Mono', fontSize: 11, color: AppColors.aiTextBody, height: 1.6)),
        ),
        const SizedBox(height: 16),
      ],
      if (data.graphs.isNotEmpty) ...[
        AiSectionLabel('Graphs Analysed (${data.graphs.length})'),
        const SizedBox(height: 8),
        ...data.graphs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AiGraphCard(index: e.key + 1, graph: e.value),
            )),
        const SizedBox(height: 8),
      ],
      const AiSectionLabel('Full Analysis'),
      const SizedBox(height: 8),
      AiMarkdownText(text: data.correctedText),
    ]);
  }
}

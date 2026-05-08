// ─────────────────────────────────────────────────────────────
// MODELS — Analysis Feature
// ─────────────────────────────────────────────────────────────

// ── Visual Analysis (analyze-visuals) ────────────────────────
class GraphAnalysis {
  final String image;
  final String analysis;

  const GraphAnalysis({required this.image, required this.analysis});

  factory GraphAnalysis.fromJson(Map<String, dynamic> j) => GraphAnalysis(
        image: j['image']?.toString() ?? '',
        analysis: j['analysis']?.toString() ?? '',
      );
}

class VisualAnalysisModel {
  final String status;
  final String documentName;
  final String rawText;
  final String correctedText;
  final int graphsAnalyzed;
  final List<GraphAnalysis> graphs;

  const VisualAnalysisModel({
    required this.status,
    required this.documentName,
    required this.rawText,
    required this.correctedText,
    required this.graphsAnalyzed,
    required this.graphs,
  });

  factory VisualAnalysisModel.fromJson(Map<String, dynamic> j) =>
      VisualAnalysisModel(
        status: j['status']?.toString() ?? '',
        documentName: j['document_name']?.toString() ?? '',
        rawText: j['raw_text']?.toString() ?? '',
        correctedText: j['corrected_text']?.toString() ?? '',
        graphsAnalyzed: j['graphs_analyzed'] as int? ?? 0,
        graphs: (j['graphs'] as List<dynamic>? ?? [])
            .map((e) => GraphAnalysis.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Audio / Summary (process-audio) ──────────────────────────
class AudioSummaryModel {
  final String filename;
  final String summary;
  final String? audioUrl;

  const AudioSummaryModel({
    required this.filename,
    required this.summary,
    this.audioUrl,
  });

  factory AudioSummaryModel.fromJson(Map<String, dynamic> j) =>
      AudioSummaryModel(
        filename: j['filename']?.toString() ?? '',
        summary: j['summary']?.toString() ?? '',
        audioUrl: j['audio_url']?.toString(),
      );
}

// ── Rules (get-rules) ─────────────────────────────────────────
// Response after double-decode:
//   { "filename": "...", "rules": "<rule text / markdown>" }
//
// The "rules" value is a plain string — could be a single rule,
// multiple rules separated by newlines, or light markdown.
// We split on newlines and render each non-empty line as a rule card.
class RulesModel {
  final String filename;

  /// Raw rules string exactly as returned by the API.
  final String rawRules;

  const RulesModel({required this.filename, required this.rawRules});

  factory RulesModel.fromJson(Map<String, dynamic> j) => RulesModel(
        filename: j['filename']?.toString() ?? '',
        rawRules: j['rules']?.toString() ?? '',
      );

  /// Split the raw string into individual rule entries.
  /// Each non-blank line is treated as one rule.
  List<String> get ruleLines => rawRules
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

// ── Definitions (get-definitions) ────────────────────────────
// Response after double-decode:
//   { "filename": "...", "definitions": "<markdown string>" }
//
// The "definitions" value is a markdown string — rendered as-is
// using the existing _MarkdownText widget.
class DefinitionsModel {
  final String filename;

  /// Raw markdown string exactly as returned by the API.
  final String markdownContent;

  const DefinitionsModel({
    required this.filename,
    required this.markdownContent,
  });

  factory DefinitionsModel.fromJson(Map<String, dynamic> j) =>
      DefinitionsModel(
        filename: j['filename']?.toString() ?? '',
        markdownContent: j['definitions']?.toString() ?? '',
      );
}

// ── Load status ───────────────────────────────────────────────
enum LoadStatus { idle, loading, success, failure }

// ── Unified Screen State ──────────────────────────────────────
class AnalysisState {
  // Visual analysis
  final LoadStatus visualStatus;
  final VisualAnalysisModel? visualData;
  final String? visualError;

  // Audio summary
  final LoadStatus summaryStatus;
  final AudioSummaryModel? summaryData;
  final String? summaryError;

  // Rules  (replaces FormulaItem list)
  final LoadStatus rulesStatus;
  final RulesModel? rulesData;
  final String? rulesError;

  // Definitions  (replaces DefinitionItem list)
  final LoadStatus definitionStatus;
  final DefinitionsModel? definitionsData;
  final String? definitionError;

  const AnalysisState({
    this.visualStatus = LoadStatus.idle,
    this.visualData,
    this.visualError,
    this.summaryStatus = LoadStatus.idle,
    this.summaryData,
    this.summaryError,
    this.rulesStatus = LoadStatus.idle,
    this.rulesData,
    this.rulesError,
    this.definitionStatus = LoadStatus.idle,
    this.definitionsData,
    this.definitionError,
  });

  AnalysisState copyWith({
    LoadStatus? visualStatus,
    VisualAnalysisModel? visualData,
    String? visualError,
    LoadStatus? summaryStatus,
    AudioSummaryModel? summaryData,
    String? summaryError,
    LoadStatus? rulesStatus,
    RulesModel? rulesData,
    String? rulesError,
    LoadStatus? definitionStatus,
    DefinitionsModel? definitionsData,
    String? definitionError,
  }) =>
      AnalysisState(
        visualStatus: visualStatus ?? this.visualStatus,
        visualData: visualData ?? this.visualData,
        visualError: visualError ?? this.visualError,
        summaryStatus: summaryStatus ?? this.summaryStatus,
        summaryData: summaryData ?? this.summaryData,
        summaryError: summaryError ?? this.summaryError,
        rulesStatus: rulesStatus ?? this.rulesStatus,
        rulesData: rulesData ?? this.rulesData,
        rulesError: rulesError ?? this.rulesError,
        definitionStatus: definitionStatus ?? this.definitionStatus,
        definitionsData: definitionsData ?? this.definitionsData,
        definitionError: definitionError ?? this.definitionError,
      );
}
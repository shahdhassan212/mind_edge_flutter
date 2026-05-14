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
  final String sessionId;

  const VisualAnalysisModel({
    required this.status,
    required this.documentName,
    required this.rawText,
    required this.correctedText,
    required this.graphsAnalyzed,
    required this.graphs,
    required this.sessionId,
  });

  factory VisualAnalysisModel.fromJson(Map<String, dynamic> j) => VisualAnalysisModel(
        status: j['status']?.toString() ?? '',
        documentName: j['document_name']?.toString() ?? '',
        rawText: j['raw_text']?.toString() ?? '',
        correctedText: j['corrected_text']?.toString() ?? '',
        graphsAnalyzed: j['graphs_analyzed'] as int? ?? 0,
        graphs: (j['graphs'] as List<dynamic>? ?? [])
            .map((e) => GraphAnalysis.fromJson(e as Map<String, dynamic>))
            .toList(),
        sessionId: j['session_id']?.toString() ?? '',
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

  factory AudioSummaryModel.fromJson(Map<String, dynamic> j) => AudioSummaryModel(
        filename: j['filename']?.toString() ?? '',
        summary: j['summary']?.toString() ?? '',
        audioUrl: j['audio_url']?.toString(),
      );
}

// ── Parsed rule card ──────────────────────────────────────────
class ParsedRule {
  final String title;
  final String formula;
  final String description;
  final List<String> variables;

  const ParsedRule({
    required this.title,
    required this.formula,
    required this.description,
    required this.variables,
  });
}

class RulesModel {
  final String filename;
  final String rawRules;

  const RulesModel({required this.filename, required this.rawRules});

  factory RulesModel.fromJson(Map<String, dynamic> j) => RulesModel(
        filename: j['filename']?.toString() ?? '',
        rawRules: j['rules']?.toString() ?? '',
      );

  /// Split the raw string into individual rule entries.
  List<String> get ruleLines =>
      rawRules.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  /// Parse rawRules markdown into structured rule cards.
  /// Handles format:
  ///   ### Title
  ///   **Formula:** `...`
  ///   **Description:** ...
  ///   **Variables:**
  ///   - var: desc
  List<ParsedRule> get parsedRules {
    final rules = <ParsedRule>[];
    final lines = rawRules.split('\n');

    String title = '';
    String formula = '';
    String description = '';
    final variables = <String>[];
    bool inVariables = false;

    void _flush() {
      if (title.isNotEmpty || formula.isNotEmpty) {
        rules.add(ParsedRule(
          title: title,
          formula: formula,
          description: description,
          variables: List.from(variables),
        ));
      }
      title = '';
      formula = '';
      description = '';
      variables.clear();
      inVariables = false;
    }

    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty) continue;

      // New rule starts at ### heading
      if (t.startsWith('###')) {
        _flush();
        title = t.replaceFirst(RegExp(r'^#{1,3}\s*'), '').trim();
        inVariables = false;
      } else if (t.startsWith('**Formula:**') || t.startsWith('**Formula**:')) {
        formula = t
            .replaceFirst(RegExp(r'\*\*Formula\*\*\s*:?\s*|\*\*Formula:\*\*\s*'), '')
            .replaceAll(RegExp(r'`'), '')
            .trim();
        inVariables = false;
      } else if (t.startsWith('**Description:**') || t.startsWith('**Description**:')) {
        description = t
            .replaceFirst(RegExp(r'\*\*Description\*\*\s*:?\s*|\*\*Description:\*\*\s*'), '')
            .trim();
        inVariables = false;
      } else if (t.startsWith('**Variables:**') || t.startsWith('**Variables**:')) {
        inVariables = true;
      } else if (inVariables && (t.startsWith('-') || t.startsWith('•'))) {
        variables.add(t.replaceFirst(RegExp(r'^[-•]\s*'), '').trim());
      } else if (t.startsWith('##') || t.startsWith('#')) {
        // h1/h2 = new section, skip
      }
    }
    _flush();

    return rules;
  }
}

// ── Parsed definition term ────────────────────────────────────
class ParsedDefinition {
  final String term;
  final String definition;

  const ParsedDefinition({required this.term, required this.definition});
}

class DefinitionsModel {
  final String filename;
  final String markdownContent;

  const DefinitionsModel({
    required this.filename,
    required this.markdownContent,
  });

  factory DefinitionsModel.fromJson(Map<String, dynamic> j) => DefinitionsModel(
        filename: j['filename']?.toString() ?? '',
        markdownContent: j['definitions']?.toString() ?? '',
      );

  /// Parse markdown definitions into term + definition pairs.
  List<ParsedDefinition> get parsedDefinitions {
    final defs = <ParsedDefinition>[];
    final lines = markdownContent.split('\n');

    for (final line in lines) {
      final t = line.trim();
      if (t.isEmpty) continue;
      // Skip headings
      if (t.startsWith('#')) continue;

      // numbered: 1. **Term**: definition  or  1. **Term (extra)**: definition
      final numberedMatch = RegExp(r'^\d+\.\s+\*\*(.+?)\*\*\s*[:\-–]\s*(.+)$').firstMatch(t);
      if (numberedMatch != null) {
        defs.add(ParsedDefinition(
          term: numberedMatch.group(1)!.trim(),
          definition: numberedMatch.group(2)!.trim(),
        ));
        continue;
      }

      // - **Term**: definition
      final bulletMatch = RegExp(r'^[-•]\s+\*\*(.+?)\*\*\s*[:\-–]\s*(.+)$').firstMatch(t);
      if (bulletMatch != null) {
        defs.add(ParsedDefinition(
          term: bulletMatch.group(1)!.trim(),
          definition: bulletMatch.group(2)!.trim(),
        ));
      }
    }

    return defs;
  }
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

  // Rules
  final LoadStatus rulesStatus;
  final RulesModel? rulesData;
  final String? rulesError;

  // Definitions
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

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

  factory VisualAnalysisModel.fromJson(Map<String, dynamic> j) => VisualAnalysisModel(
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

  factory AudioSummaryModel.fromJson(Map<String, dynamic> j) => AudioSummaryModel(
        filename: j['filename']?.toString() ?? '',
        summary: j['summary']?.toString() ?? '',
        audioUrl: j['audio_url']?.toString(),
      );
}

// ── Formula Sheet ─────────────────────────────────────────────
class FormulaItem {
  final String id;
  final String label;
  final String expression;
  final String description;
  final String category;
  final List<String> variables;

  const FormulaItem({
    required this.id,
    required this.label,
    required this.expression,
    required this.description,
    required this.category,
    required this.variables,
  });

  factory FormulaItem.fromJson(Map<String, dynamic> j) => FormulaItem(
        id: j['id']?.toString() ?? '',
        label: j['label']?.toString() ?? '',
        expression: j['expression']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        category: j['category']?.toString() ?? 'General',
        variables: (j['variables'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );

  static List<FormulaItem> placeholders() => const [
        FormulaItem(
          id: '1',
          label: 'Rate Law',
          expression: 'rate = k[A]ᵐ[B]ⁿ',
          description: 'Relates reaction rate to reactant concentrations and orders.',
          category: 'Kinetics',
          variables: ['k = rate constant', 'm = order w.r.t. A', 'n = order w.r.t. B'],
        ),
        FormulaItem(
          id: '2',
          label: 'Arrhenius Equation',
          expression: 'k = Ae^(−Ea/RT)',
          description: 'Describes dependence of rate constant on temperature.',
          category: 'Kinetics',
          variables: [
            'A = frequency factor',
            'Eₐ = activation energy',
            'R = 8.314 J/mol·K',
            'T = temperature (K)',
          ],
        ),
        FormulaItem(
          id: '3',
          label: 'Gibbs Free Energy',
          expression: 'ΔG = ΔH − TΔS',
          description: 'Determines spontaneity of a reaction at constant T & P.',
          category: 'Thermodynamics',
          variables: ['ΔH = enthalpy change', 'T = temperature (K)', 'ΔS = entropy change'],
        ),
        FormulaItem(
          id: '4',
          label: 'Henderson–Hasselbalch',
          expression: 'pH = pKₐ + log([A⁻]/[HA])',
          description: 'Calculates pH of a buffer solution.',
          category: 'Acid–Base',
          variables: ['pKₐ = −log(Kₐ)', '[A⁻] = conjugate base', '[HA] = weak acid'],
        ),
        FormulaItem(
          id: '5',
          label: 'Beer–Lambert Law',
          expression: 'A = εlc',
          description: 'Relates absorbance to concentration in spectroscopy.',
          category: 'Spectroscopy',
          variables: [
            'ε = molar absorptivity',
            'l = path length (cm)',
            'c = concentration (mol/L)',
          ],
        ),
      ];
}

// ── Unified Screen State ──────────────────────────────────────
enum LoadStatus { idle, loading, success, failure }

class AnalysisState {
  // Visual analysis
  final LoadStatus visualStatus;
  final VisualAnalysisModel? visualData;
  final String? visualError;

  // Audio summary
  final LoadStatus summaryStatus;
  final AudioSummaryModel? summaryData;
  final String? summaryError;

  // Formula sheet
  final LoadStatus formulaStatus;
  final List<FormulaItem> formulas;
  final String? formulaFilter;

  const AnalysisState({
    this.visualStatus = LoadStatus.idle,
    this.visualData,
    this.visualError,
    this.summaryStatus = LoadStatus.idle,
    this.summaryData,
    this.summaryError,
    this.formulaStatus = LoadStatus.idle,
    this.formulas = const [],
    this.formulaFilter,
  });

  AnalysisState copyWith({
    LoadStatus? visualStatus,
    VisualAnalysisModel? visualData,
    String? visualError,
    LoadStatus? summaryStatus,
    AudioSummaryModel? summaryData,
    String? summaryError,
    LoadStatus? formulaStatus,
    List<FormulaItem>? formulas,
    Object? formulaFilter = _sentinel,
  }) =>
      AnalysisState(
        visualStatus: visualStatus ?? this.visualStatus,
        visualData: visualData ?? this.visualData,
        visualError: visualError ?? this.visualError,
        summaryStatus: summaryStatus ?? this.summaryStatus,
        summaryData: summaryData ?? this.summaryData,
        summaryError: summaryError ?? this.summaryError,
        formulaStatus: formulaStatus ?? this.formulaStatus,
        formulas: formulas ?? this.formulas,
        formulaFilter: formulaFilter == _sentinel ? this.formulaFilter : formulaFilter as String?,
      );

  List<FormulaItem> get filteredFormulas => formulaFilter == null
      ? formulas
      : formulas.where((f) => f.category == formulaFilter).toList();

  List<String> get categories => formulas.map((f) => f.category).toSet().toList();
}

const _sentinel = Object();

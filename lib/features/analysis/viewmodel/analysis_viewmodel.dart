import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/analysis_models.dart';
import '../repository/analysis_repository.dart';
import '../../auth/auth_view_model.dart'; // exports dioClientProvider

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────

// Reuses the app's shared DioClient — token handled automatically
final analysisRepoProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepository(client: ref.watch(dioClientProvider)),
);

// Scoped per screen via .family(fileName)
final analysisViewModelProvider =
    StateNotifierProvider.family<AnalysisViewModel, AnalysisState, String>(
  (ref, fileName) {
    final repo = ref.watch(analysisRepoProvider);
    return AnalysisViewModel(repo: repo, fileName: fileName);
  },
);

// ─────────────────────────────────────────────────────────────
// VIEW-MODEL
// ─────────────────────────────────────────────────────────────
class AnalysisViewModel extends StateNotifier<AnalysisState> {
  final AnalysisRepository _repo;
  final String _fileName;

  AnalysisViewModel({required AnalysisRepository repo, required String fileName})
      : _repo = repo,
        _fileName = fileName,
        super(const AnalysisState());

  // ── Sequential: analyze-visuals → process-audio ───────────
  // process-audio needs document_name from analyze-visuals response,
  // so both calls MUST be sequential — never parallel.
  Future<void> loadVisualAnalysisThenSummary(File file) async {
    if (state.visualStatus == LoadStatus.loading) return;

    // Mark both as loading upfront so the UI shows skeletons immediately
    state = state.copyWith(
      visualStatus: LoadStatus.loading,
      summaryStatus: LoadStatus.loading,
      visualError: null,
      summaryError: null,
    );

    // ── Step 1: analyze-visuals ─────────────────────────────
    VisualAnalysisModel? visualData;
    try {
      visualData = await _repo.analyzeVisuals(file);
      state = state.copyWith(
        visualStatus: LoadStatus.success,
        visualData: visualData,
      );
    } catch (e) {
      state = state.copyWith(
        visualStatus: LoadStatus.failure,
        visualError: e.toString(),
        summaryStatus: LoadStatus.failure,
        summaryError: 'Visual analysis failed — cannot generate summary.',
      );
      return; // no document_name → cannot proceed
    }

    // ── Step 2: process-audio using document_name ───────────
    try {
      final summaryData = await _repo.processAudio(visualData.documentName);
      state = state.copyWith(
        summaryStatus: LoadStatus.success,
        summaryData: summaryData,
      );
    } catch (e) {
      state = state.copyWith(
        summaryStatus: LoadStatus.failure,
        summaryError: e.toString(),
      );
    }
  }

  // ── Formulas ───────────────────────────────────────────────
  Future<void> loadFormulas() async {
    if (state.formulaStatus == LoadStatus.loading) return;

    state = state.copyWith(formulaStatus: LoadStatus.loading);
    try {
      final items = await _repo.fetchFormulas(_fileName);
      state = state.copyWith(
        formulaStatus: LoadStatus.success,
        formulas: items,
      );
    } catch (_) {
      state = state.copyWith(
        formulaStatus: LoadStatus.success,
        formulas: FormulaItem.placeholders(),
      );
    }
  }

  // ── Filter ─────────────────────────────────────────────────
  void setFormulaFilter(String? category) =>
      state = state.copyWith(formulaFilter: category);

  // ── Retry ──────────────────────────────────────────────────
  // Retry everything from the start
  void retryAll(File file) => loadVisualAnalysisThenSummary(file);

  // Retry only summary if visuals already succeeded
  Future<void> retrySummary() async {
    final docName = state.visualData?.documentName;
    if (docName == null) return;

    state = state.copyWith(summaryStatus: LoadStatus.loading, summaryError: null);
    try {
      final data = await _repo.processAudio(docName);
      state = state.copyWith(
        summaryStatus: LoadStatus.success,
        summaryData: data,
      );
    } catch (e) {
      state = state.copyWith(
        summaryStatus: LoadStatus.failure,
        summaryError: e.toString(),
      );
    }
  }
}
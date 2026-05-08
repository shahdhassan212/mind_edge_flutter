import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/analysis_models.dart';
import '../repository/analysis_repository.dart';
import '../../auth/auth_view_model.dart';

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────
final analysisRepoProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepository(client: ref.watch(dioClientProvider)),
);

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

  AnalysisViewModel({
    required AnalysisRepository repo,
    required String fileName,
  })  : _repo = repo,
        _fileName = fileName,
        super(const AnalysisState());

  // ── Sequential: analyze-visuals → then parallel ──────────
  Future<void> loadAll(File file) async {
    if (state.visualStatus == LoadStatus.loading) return;

    state = state.copyWith(
      visualStatus: LoadStatus.loading,
      summaryStatus: LoadStatus.loading,
      rulesStatus: LoadStatus.loading,
      definitionStatus: LoadStatus.loading,
      visualError: null,
      summaryError: null,
      rulesError: null,
      definitionError: null,
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
        summaryError: 'Visual analysis failed — cannot continue.',
        rulesStatus: LoadStatus.failure,
        rulesError: 'Visual analysis failed — cannot load rules.',
        definitionStatus: LoadStatus.failure,
        definitionError: 'Visual analysis failed — cannot load definitions.',
      );
      return;
    }

    final docName = visualData.documentName;

    // ── Steps 2-4: parallel ─────────────────────────────────
    await Future.wait([
      // process-audio → summary
      _repo.processAudio(docName, tts: true).then((data) {
        state = state.copyWith(
          summaryStatus: LoadStatus.success,
          summaryData: data,
        );
      }).catchError((e) {
        state = state.copyWith(
          summaryStatus: LoadStatus.failure,
          summaryError: e.toString(),
        );
      }),

      // get-rules
      _repo.fetchRules(docName).then((data) {
        state = state.copyWith(
          rulesStatus: LoadStatus.success,
          rulesData: data,
        );
      }).catchError((e) {
        state = state.copyWith(
          rulesStatus: LoadStatus.failure,
          rulesError: e.toString(),
        );
      }),

      // get-definitions
      _repo.fetchDefinitions(docName).then((data) {
        state = state.copyWith(
          definitionStatus: LoadStatus.success,
          definitionsData: data,
        );
      }).catchError((e) {
        state = state.copyWith(
          definitionStatus: LoadStatus.failure,
          definitionError: e.toString(),
        );
      }),
    ]);
  }

  // ── Retry helpers ──────────────────────────────────────────
  void retryAll(File file) => loadAll(file);

  Future<void> retrySummary() async {
    final docName = state.visualData?.documentName;
    if (docName == null) return;
    state = state.copyWith(
        summaryStatus: LoadStatus.loading, summaryError: null);
    try {
      final data = await _repo.processAudio(docName, tts: true);
      state = state.copyWith(
          summaryStatus: LoadStatus.success, summaryData: data);
    } catch (e) {
      state = state.copyWith(
          summaryStatus: LoadStatus.failure, summaryError: e.toString());
    }
  }

  Future<void> retryRules() async {
    final docName = state.visualData?.documentName;
    if (docName == null) return;
    state = state.copyWith(rulesStatus: LoadStatus.loading, rulesError: null);
    try {
      final data = await _repo.fetchRules(docName);
      state =
          state.copyWith(rulesStatus: LoadStatus.success, rulesData: data);
    } catch (e) {
      state = state.copyWith(
          rulesStatus: LoadStatus.failure, rulesError: e.toString());
    }
  }

  Future<void> retryDefinitions() async {
    final docName = state.visualData?.documentName;
    if (docName == null) return;
    state = state.copyWith(
        definitionStatus: LoadStatus.loading, definitionError: null);
    try {
      final data = await _repo.fetchDefinitions(docName);
      state = state.copyWith(
          definitionStatus: LoadStatus.success, definitionsData: data);
    } catch (e) {
      state = state.copyWith(
          definitionStatus: LoadStatus.failure,
          definitionError: e.toString());
    }
  }
}
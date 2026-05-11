// features/study_plan/providers/study_plan_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_view_model.dart';
import '../model/study_plan_models.dart';
import '../repository/study_plan_repository.dart';

final studyPlanRepositoryProvider = Provider<StudyPlanRepository>((ref) {
  return StudyPlanRepository(client: ref.watch(dioClientProvider));
});

class StudyPlanViewModel extends StateNotifier<StudyPlanState> {
  final StudyPlanRepository _repo;

  StudyPlanViewModel(this._repo) : super(const StudyPlanState());

  // ── Generate ──────────────────────────────────────────────
  Future<StudyPlanResponse?> generatePlan({
    required String filename,
    required int days,
    required int hoursPerDay,
    required String level,
  }) async {
    state = state.copyWith(generateStatus: StudyPlanStatus.loading, error: null);
    try {
      final plan = await _repo.generatePlan(
        filename: filename,
        days: days,
        hoursPerDay: hoursPerDay,
        level: level,
      );
      state = state.copyWith(
        generateStatus: StudyPlanStatus.success,
        planData: plan,
      );
      // Refresh dashboard after generate
      await fetchDashboard();
      return plan;
    } catch (e) {
      state = state.copyWith(
        generateStatus: StudyPlanStatus.failure,
        error: e.toString(),
      );
      return null;
    }
  }

  // ── Dashboard ─────────────────────────────────────────────
  Future<void> fetchDashboard() async {
    state = state.copyWith(dashboardStatus: StudyPlanStatus.loading, error: null);
    try {
      final tasks = await _repo.fetchDashboard();
      state = state.copyWith(
        dashboardStatus: StudyPlanStatus.success,
        dashboardTasks: tasks,
      );
    } catch (e) {
      state = state.copyWith(
        dashboardStatus: StudyPlanStatus.failure,
        error: e.toString(),
      );
    }
  }

  // ── Archive names ─────────────────────────────────────────
  Future<void> fetchArchiveNames() async {
    state = state.copyWith(archiveStatus: StudyPlanStatus.loading, error: null);
    try {
      final items = await _repo.fetchArchiveNames();
      state = state.copyWith(
        archiveStatus: StudyPlanStatus.success,
        archiveItems: items,
      );
    } catch (e) {
      state = state.copyWith(
        archiveStatus: StudyPlanStatus.failure,
        error: e.toString(),
      );
    }
  }

  // ── Plan by file ──────────────────────────────────────────
  Future<void> fetchPlanByFile(String fileName) async {
    state = state.copyWith(selectedPlanStatus: StudyPlanStatus.loading, error: null);
    try {
      final plan = await _repo.fetchPlanByFile(fileName);
      state = state.copyWith(
        selectedPlanStatus: StudyPlanStatus.success,
        selectedPlan: plan,
      );
    } catch (e) {
      state = state.copyWith(
        selectedPlanStatus: StudyPlanStatus.failure,
        error: e.toString(),
      );
    }
  }

  // ── Toggle task ───────────────────────────────────────────
  Future<void> toggleTask(int taskId) async {
    try {
      await _repo.toggleTask(taskId);
      // Update locally for instant UI feedback
      final updated = state.dashboardTasks.map((t) {
        if (t.id == taskId) return t.copyWith(isCompleted: !t.isCompleted);
        return t;
      }).toList();
      state = state.copyWith(dashboardTasks: updated);
    } catch (_) {
      // Silent fail — UI stays as is
    }
  }

  void reset() => state = const StudyPlanState();
}

final studyPlanProvider =
    StateNotifierProvider<StudyPlanViewModel, StudyPlanState>(
  (ref) => StudyPlanViewModel(ref.watch(studyPlanRepositoryProvider)),
);
// features/analysis/providers/quiz_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_view_model.dart';
import '../model/quiz_models.dart';
import '../repository/quiz_repository.dart';

// ── Repo provider ─────────────────────────────────────────────
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(client: ref.watch(dioClientProvider));
});

// ── ViewModel ─────────────────────────────────────────────────
class QuizViewModel extends StateNotifier<QuizState> {
  final QuizRepository _repo;

  QuizViewModel(this._repo) : super(const QuizState());

  Future<void> generateQuiz({
    required String filename,
    required int numQuestions,
    required QuizType quizType,
  }) async {
    state = state.copyWith(generateStatus: QuizLoadStatus.loading, error: null);
    try {
      final data = await _repo.generateQuiz(
        filename: filename,
        numQuestions: numQuestions,
        quizType: quizType,
      );
      state = state.copyWith(
        generateStatus: QuizLoadStatus.success,
        quizData: data,
      );
    } catch (e) {
      state = state.copyWith(
        generateStatus: QuizLoadStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> submitQuiz({required List<String> answers}) async {
    final quizId = state.quizData?.quizId;
    if (quizId == null) return;

    state = state.copyWith(submitStatus: QuizLoadStatus.loading, error: null);
    try {
      final result = await _repo.submitQuiz(quizId: quizId, answers: answers);
      state = state.copyWith(
        submitStatus: QuizLoadStatus.success,
        resultData: result,
      );
    } catch (e) {
      state = state.copyWith(
        submitStatus: QuizLoadStatus.failure,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const QuizState();
}

// ── Provider — keyed by filename ──────────────────────────────
final quizViewModelProvider = StateNotifierProvider.family<QuizViewModel, QuizState, String>(
  (ref, filename) {
    final repo = ref.watch(quizRepositoryProvider);
    return QuizViewModel(repo);
  },
);

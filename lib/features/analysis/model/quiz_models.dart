// features/quiz/model/quiz_models.dart

// ── Generate request ──────────────────────────────────────────
class QuizGenerateRequest {
  final String filename;
  final int numQuestions;

  const QuizGenerateRequest({
    required this.filename,
    required this.numQuestions,
  });

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'numQuestions': numQuestions,
      };
}

// ── Single question ───────────────────────────────────────────
enum QuizQuestionType { mcq, text }

class QuizQuestion {
  final String question;
  final QuizQuestionType type;
  final List<String>? options; // only for mcq

  const QuizQuestion({
    required this.question,
    required this.type,
    this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final type = json['type'] == 'mcq' ? QuizQuestionType.mcq : QuizQuestionType.text;
    return QuizQuestion(
      question: json['question'] as String,
      type: type,
      options: type == QuizQuestionType.mcq
          ? List<String>.from(json['options'] as List)
          : null,
    );
  }
}

// ── Generate response ─────────────────────────────────────────
class QuizGenerateResponse {
  final String quizId;
  final List<QuizQuestion> questions;
  final String filename;

  const QuizGenerateResponse({
    required this.quizId,
    required this.questions,
    required this.filename,
  });

  factory QuizGenerateResponse.fromJson(Map<String, dynamic> json) {
    return QuizGenerateResponse(
      quizId: json['quiz_id'] as String,
      questions: (json['quiz'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      filename: json['filename'] as String,
    );
  }
}

// ── Submit request ────────────────────────────────────────────
class QuizSubmitRequest {
  final String quizId;
  final List<String> answers;

  const QuizSubmitRequest({
    required this.quizId,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'answers': answers,
      };
}

// ── Single result ─────────────────────────────────────────────
class QuizQuestionResult {
  final String question;
  final bool isCorrect;
  final String explanation;

  const QuizQuestionResult({
    required this.question,
    required this.isCorrect,
    required this.explanation,
  });

  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) {
    return QuizQuestionResult(
      question: json['question'] as String,
      isCorrect: json['is_correct'] as bool,
      explanation: json['explanation'] as String,
    );
  }
}

// ── Submit response ───────────────────────────────────────────
class QuizSubmitResponse {
  final int score;
  final int total;
  final List<QuizQuestionResult> results;

  const QuizSubmitResponse({
    required this.score,
    required this.total,
    required this.results,
  });

  double get percentage => total == 0 ? 0 : score / total;

  factory QuizSubmitResponse.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResponse(
      score: json['score'] as int,
      total: json['total'] as int,
      results: (json['results'] as List)
          .map((r) => QuizQuestionResult.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Quiz state ────────────────────────────────────────────────
enum QuizLoadStatus { idle, loading, success, failure }

class QuizState {
  final QuizLoadStatus generateStatus;
  final QuizLoadStatus submitStatus;
  final QuizGenerateResponse? quizData;
  final QuizSubmitResponse? resultData;
  final String? error;

  const QuizState({
    this.generateStatus = QuizLoadStatus.idle,
    this.submitStatus = QuizLoadStatus.idle,
    this.quizData = null,
    this.resultData = null,
    this.error = null,
  });

  QuizState copyWith({
    QuizLoadStatus? generateStatus,
    QuizLoadStatus? submitStatus,
    QuizGenerateResponse? quizData,
    QuizSubmitResponse? resultData,
    String? error,
  }) =>
      QuizState(
        generateStatus: generateStatus ?? this.generateStatus,
        submitStatus: submitStatus ?? this.submitStatus,
        quizData: quizData ?? this.quizData,
        resultData: resultData ?? this.resultData,
        error: error ?? this.error,
      );
}
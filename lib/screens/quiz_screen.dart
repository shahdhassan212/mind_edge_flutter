import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/analysis/model/quiz_models.dart';
import '../features/analysis/providers/quiz_providers.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String filename;
  final int numQuestions;

  const QuizScreen({
    super.key,
    required this.filename,
    this.numQuestions = 10,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedCount;
  QuizType? _selectedType;

  List<String> _answers = [];
  final Map<int, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    // Do NOT auto-generate — wait for user to pick count and type
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int index) {
    return _textControllers.putIfAbsent(index, () => TextEditingController());
  }

  void _initAnswers(int count) {
    if (_answers.length != count) {
      _answers = List.filled(count, '');
    }
  }

  void _goNext(List<QuizQuestion> questions) {
    final q = questions[_currentIndex];
    if (q.type == QuizQuestionType.essay) {
      _answers[_currentIndex] = _controllerFor(_currentIndex).text.trim();
    }

    if (_currentIndex < questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submit();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  Future<void> _submit() async {
    await ref.read(quizViewModelProvider(widget.filename).notifier).submitQuiz(answers: _answers);

    final result = ref.read(quizViewModelProvider(widget.filename)).resultData;
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/quiz-result',
      arguments: {
        'result': result,
        'filename': widget.filename,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Step 1: pick count
    if (_selectedCount == null) return _buildCountSelector();
    // ── Step 2: pick type
    if (_selectedType == null) return _buildTypeSelector();

    final state = ref.watch(quizViewModelProvider(widget.filename));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)],
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gold.withOpacity(0.12), Colors.transparent],
                  radius: 0.68,
                ),
              ),
            ),
          ),
          SafeArea(
            child: switch (state.generateStatus) {
              QuizLoadStatus.idle || QuizLoadStatus.loading => _buildLoading(),
              QuizLoadStatus.failure => _buildError(state.error),
              QuizLoadStatus.success => _buildQuiz(state),
            },
          ),
        ]),
      ),
    );
  }

  // ── Count selector screen ─────────────────────────────────────
  Widget _buildCountSelector() {
    final controller = TextEditingController(text: '${widget.numQuestions}');
    String? errorText;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)],
          ),
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setLocal) {
              void tryStart() {
                final val = int.tryParse(controller.text.trim());
                if (val == null || val < 5 || val > 30) {
                  setLocal(() => errorText = 'Please enter a number between 5 and 30');
                  return;
                }
                setState(() => _selectedCount = val);
              }

              return Column(children: [
                // ── Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                  child: Row(children: [
                    _NavBtn(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text('✕', style: TextStyle(fontSize: 14, color: AppColors.cocoa)),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text('New Quiz',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cocoaDeep)),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ]),
                ),

                const Spacer(),

                // ── Icon + title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('✦', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'How many questions?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cocoaDeep,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter a number between 5 and 30',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.muted.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 32),

                // ── Input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.62),
                          border: Border.all(
                            color: errorText != null
                                ? const Color(0xFFA32D2D)
                                : const Color(0xFFB48C50).withOpacity(0.30),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.sm,
                        ),
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          onChanged: (_) => setLocal(() => errorText = null),
                          onSubmitted: (_) => tryStart(),
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cocoaDeep,
                            letterSpacing: -0.5,
                          ),
                          decoration: InputDecoration(
                            hintText: '10',
                            hintStyle: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted.withOpacity(0.3),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            color: Color(0xFFA32D2D),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // ── Start button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                  child: GestureDetector(
                    onTap: tryStart,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: AppGradients.ctaButton,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.btn,
                      ),
                      child: const Text(
                        'Start Quiz  →',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  // ── Type selector screen ──────────────────────────────────────
  Widget _buildTypeSelector() {
    final types = QuizType.values;
    QuizType selected = QuizType.mix;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)],
          ),
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Column(children: [
                // ── Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                  child: Row(children: [
                    _NavBtn(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCount = null),
                        child: const Center(
                          child: Text('←', style: TextStyle(fontSize: 16, color: AppColors.cocoa)),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text('New Quiz',
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cocoaDeep)),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ]),
                ),

                const Spacer(),

                // ── Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(child: Text('📝', style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 18),
                    const Text('Question Type',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cocoaDeep,
                          letterSpacing: -0.4,
                        )),
                    const SizedBox(height: 8),
                    Text('Choose the type of questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: AppColors.muted.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                        )),
                  ]),
                ),

                const SizedBox(height: 28),

                // ── Type options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: types.map((type) {
                      final isSelected = selected == type;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setLocal(() => selected = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cocoa.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.cocoa
                                    : const Color(0xFFB48C50).withOpacity(0.18),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppShadows.sm,
                            ),
                            child: Row(children: [
                              // Radio indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.cocoa : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.cocoa
                                        : AppColors.muted.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(Icons.check, size: 12, color: Colors.white))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(type.label,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? AppColors.cocoa : AppColors.cocoaDeep,
                                        )),
                                    Text(type.description,
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 11,
                                          color: AppColors.muted.withOpacity(0.7),
                                          fontWeight: FontWeight.w300,
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Spacer(),

                // ── Start button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = selected);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(quizViewModelProvider(widget.filename).notifier).generateQuiz(
                              filename: widget.filename,
                              numQuestions: _selectedCount!,
                              quizType: selected,
                            );
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: AppGradients.ctaButton,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.btn,
                      ),
                      child: const Text('Start Quiz  →',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          )),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: AppColors.gold),
        SizedBox(height: 16),
        Text('Generating your quiz…',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: AppColors.muted)),
      ]),
    );
  }

  // ── Error ─────────────────────────────────────────────────────
  Widget _buildError(String? msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⚠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(msg ?? 'Failed to generate quiz',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: AppColors.cocoaDeep)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => ref.read(quizViewModelProvider(widget.filename).notifier).generateQuiz(
                filename: widget.filename,
                numQuestions: _selectedCount ?? widget.numQuestions,
                quizType: _selectedType ?? QuizType.mix),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppGradients.ctaButton,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Quiz body ─────────────────────────────────────────────────
  Widget _buildQuiz(QuizState state) {
    final questions = state.quizData!.questions;
    final total = questions.length;

    // lazy init answers list
    _initAnswers(total);

    final q = questions[_currentIndex];
    final questionNumber = _currentIndex + 1;
    final isLast = _currentIndex == total - 1;

    return Column(children: [
      // ── Nav bar
      Padding(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
        child: Row(children: [
          _NavBtn(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Center(
                child: Text('✕', style: TextStyle(fontSize: 14, color: AppColors.cocoa)),
              ),
            ),
          ),
          const Spacer(),
          const Text('Quiz',
              style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cocoaDeep)),
          const Spacer(),
          _NavBtn(
            child: const Center(
              child: Text('⋯', style: TextStyle(fontSize: 13, color: AppColors.cocoa)),
            ),
          ),
        ]),
      ),

      // ── Progress bar
      Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        child: Stack(children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.cocoa.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          FractionallySizedBox(
            widthFactor: questionNumber / total,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(children: [
                Container(
                  height: 3,
                  decoration: const BoxDecoration(gradient: AppGradients.progress),
                ),
                ShimmerOverlay(duration: const Duration(milliseconds: 2000)),
              ]),
            ),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(26, 5, 26, 0),
        child: Text(
          'Question $questionNumber of $total · ${total - questionNumber} remaining',
          style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.66),
        ),
      ),

      // ── Scrollable content
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(children: [
            // Question card
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.62),
                  border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.md,
                ),
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        height: 3,
                        decoration: const BoxDecoration(gradient: AppGradients.progress),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(
                          q.type == QuizQuestionType.mcq
                              ? 'MULTIPLE CHOICE'
                              : q.type == QuizQuestionType.trueFalse
                                  ? 'TRUE / FALSE'
                                  : 'WRITTEN ANSWER',
                          style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.33,
                              color: AppColors.muted),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        q.question,
                        style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cocoaDeep,
                            letterSpacing: -0.15,
                            height: 1.4),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),

            // Answer area
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: q.type == QuizQuestionType.mcq
                  ? _buildMcqOptions(q, _currentIndex)
                  : q.type == QuizQuestionType.trueFalse
                      ? _buildTrueFalseOptions(_currentIndex)
                      : _buildTextAnswer(_currentIndex),
            ),
          ]),
        ),
      ),

      // ── Bottom nav
      Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 20),
        child: Row(children: [
          GestureDetector(
            onTap: _goPrev,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.sm,
              ),
              child: Text(
                '← Prev',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _currentIndex == 0 ? AppColors.muted : AppColors.cocoa),
              ),
            ),
          ),
          const Spacer(),
          // Dot indicators (max 5 visible)
          _buildDots(total),
          const Spacer(),
          GestureDetector(
            onTap: state.submitStatus == QuizLoadStatus.loading ? null : () => _goNext(questions),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                gradient: AppGradients.ctaButton,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.btn,
              ),
              child: state.submitStatus == QuizLoadStatus.loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLast ? 'Submit →' : 'Next →',
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white),
                    ),
            ),
          ),
        ]),
      ),
    ]);
  }

  // ── MCQ options ───────────────────────────────────────────────
  Widget _buildTrueFalseOptions(int questionIndex) {
    final options = ['True', 'False'];
    return Column(
      children: options.map((opt) {
        final selected = _answers[questionIndex] == opt;
        final isTrue = opt == 'True';
        final selColor = isTrue ? const Color(0xFF2A9D6A) : const Color(0xFFC05A32);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() => _answers[questionIndex] = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? selColor.withOpacity(0.08) : Colors.white.withOpacity(0.6),
                border: Border.all(
                  color: selected ? selColor : const Color(0xFFB48C50).withOpacity(0.18),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppShadows.sm,
              ),
              child: Row(children: [
                Icon(
                  isTrue ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  size: 20,
                  color: selected ? selColor : AppColors.muted,
                ),
                const SizedBox(width: 12),
                Text(opt,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? selColor : AppColors.cocoaDeep,
                    )),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMcqOptions(QuizQuestion q, int questionIndex) {
    final options = q.options ?? [];
    return Column(
      children: options.asMap().entries.map((e) {
        final i = e.key;
        final option = e.value;

        // Strip leading "A) " / "B) " etc. for the label letter
        final letterMatch = RegExp(r'^([A-D])\)').firstMatch(option);
        final letter = letterMatch != null ? letterMatch.group(1)! : String.fromCharCode(65 + i);
        final displayText = letterMatch != null ? option.substring(letterMatch.end).trim() : option;

        final selected = _answers[questionIndex] == option;

        return Padding(
          padding: EdgeInsets.only(bottom: i < options.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _answers[questionIndex] = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.cocoa.withOpacity(0.06) : Colors.white.withOpacity(0.6),
                border: Border.all(
                  color: selected ? AppColors.cocoa : const Color(0xFFB48C50).withOpacity(0.14),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: AppColors.cocoa.withOpacity(0.09),
                            blurRadius: 0,
                            spreadRadius: 3),
                        ...AppShadows.sm
                      ]
                    : AppShadows.sm,
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: selected ? AppGradients.ctaButton : null,
                    color: selected ? null : AppColors.cocoa.withOpacity(0.08),
                    border: Border.all(
                      color: selected ? Colors.transparent : AppColors.cocoa.withOpacity(0.18),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(letter,
                        style: TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected ? AppColors.white : AppColors.cocoa)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(displayText,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.cocoaDeep,
                          height: 1.4)),
                ),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Text answer ───────────────────────────────────────────────
  Widget _buildTextAnswer(int questionIndex) {
    final controller = _controllerFor(questionIndex);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: TextField(
        controller: controller,
        maxLines: 6,
        minLines: 4,
        style: const TextStyle(
            fontFamily: 'DM Sans', fontSize: 13, color: AppColors.cocoaDeep, height: 1.5),
        decoration: InputDecoration(
          hintText: 'Write your answer here…',
          hintStyle: TextStyle(
              fontFamily: 'DM Sans', fontSize: 13, color: AppColors.muted.withOpacity(0.6)),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
        onChanged: (v) => _answers[questionIndex] = v,
      ),
    );
  }

  // ── Dot indicators ────────────────────────────────────────────
  Widget _buildDots(int total) {
    const maxDots = 5;
    final count = total.clamp(0, maxDots);
    return Row(
      children: List.generate(count, (i) {
        final active = i == _currentIndex.clamp(0, count - 1);
        return Padding(
          padding: EdgeInsets.only(right: i < count - 1 ? 5 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 14 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.gold
                  : AppColors.cocoa.withOpacity(i < _currentIndex ? 1 : 0.18),
              borderRadius: BorderRadius.circular(active ? 3 : 100),
            ),
          ),
        );
      }),
    );
  }
}

// ── Small reusable nav button ──────────────────────────────────
class _NavBtn extends StatelessWidget {
  final Widget child;
  const _NavBtn({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16)),
          boxShadow: AppShadows.sm,
        ),
        child: child,
      );
}

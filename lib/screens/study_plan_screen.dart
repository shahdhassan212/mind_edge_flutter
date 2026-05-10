// screens/study_plan_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/files/providers/files_provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  ConsumerState<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends ConsumerState<StudyPlanScreen> {
  final _subjectCtrl = TextEditingController(text: 'Organic Chemistry');
  final _daysCtrl    = TextEditingController(text: '30');

  int _daily = 1; // 0=1h 1=2h 2=3h+
  int _diff  = 0; // 0=Beginner 1=Advanced

  String? _uploadedFileName;
  bool _uploadSuccess = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null || !mounted) return;

    setState(() {
      _uploadedFileName = picked.name;
      _uploadSuccess = false;
    });

    final ok = await ref
        .read(uploadProvider.notifier)
        .upload(picked.path!, picked.name);

    if (!mounted) return;
    setState(() => _uploadSuccess = ok);

    if (!ok) {
      AppSnackBar.show(context, 'Upload failed — please try again');
    }
  }

  // TODO: call study-plan endpoint when ready
  // payload: subject, days, dailyHours, difficulty, fileName
  void _generate() => Navigator.pushNamed(context, '/dashboard');

  @override
  Widget build(BuildContext context) {
    final isUploading = ref.watch(uploadProvider).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFFDFAF4),
              Color(0xFFF4E9D6),
              Color(0xFFECDAC0),
            ],
          ),
        ),
        child: Stack(children: [
          AppDecorOrb(
              top: -60, right: -60, size: 240,
              color: AppColors.gold.withOpacity(0.12)),
          SafeArea(
            child: Column(children: [
              // ── Nav bar (custom — has "Save" instead of SizedBox)
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                child: Row(children: [
                  const AppBackButton(),
                  const Spacer(),
                  const Text('New Study Plan',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cocoaDeep)),
                  const Spacer(),
                  const Text('Save',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.cocoa)),
                ]),
              ),

              const AuthStepBar(steps: 3, filled: 1),
              const StepLabel('Step 1 of 3 — Subject & Goals'),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).viewInsets.bottom + 20),
                  child: Column(children: [
                    // ── Subject input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SUBJECT OR TOPIC',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B4C3B),
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 5),
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(18, 4, 18, 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.72),
                              border: Border.all(
                                  color: AppColors.cocoa, width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.cocoa.withOpacity(0.08),
                                    blurRadius: 0,
                                    spreadRadius: 3),
                                ...AppShadows.sm,
                              ],
                            ),
                            child: TextField(
                              controller: _subjectCtrl,
                              style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoaDeep),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Options
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                      child: Column(children: [
                        _DaysInput(controller: _daysCtrl),
                        const SizedBox(height: 9),
                        _OptionRow(
                            title: 'Daily Goal',
                            sub: 'Hours per day',
                            options: const ['1h', '2h', '3h+'],
                            selected: _daily,
                            onSelect: (i) =>
                                setState(() => _daily = i)),
                        const SizedBox(height: 9),
                        _OptionRow(
                            title: 'Difficulty',
                            sub: 'Current level',
                            options: const ['Beginner', 'Advanced'],
                            selected: _diff,
                            onSelect: (i) =>
                                setState(() => _diff = i)),
                      ]),
                    ),

                    // ── Upload zone
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                      child: GestureDetector(
                        onTap: isUploading ? null : _pickAndUpload,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppShadows.sm,
                          ),
                          child: _DashedBorder(
                            color: _uploadSuccess
                                ? AppColors.gold.withOpacity(0.55)
                                : const Color(0xFFB48C50)
                                    .withOpacity(0.3),
                            borderRadius: 18,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(
                                        _uploadSuccess ? 0.20 : 0.12),
                                    border: Border.all(
                                        color: AppColors.gold
                                            .withOpacity(0.24)),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: isUploading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.gold,
                                            ),
                                          )
                                        : Text(
                                            _uploadSuccess ? '✅' : '📄',
                                            style: const TextStyle(
                                                fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isUploading
                                            ? 'Uploading…'
                                            : _uploadedFileName ??
                                                'Upload Course Materials',
                                        style: const TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.cocoaDeep),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _uploadSuccess
                                            ? 'File uploaded successfully'
                                            : 'PDFs, notes, or scan via OCR',
                                        style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 10.5,
                                            color: _uploadSuccess
                                                ? AppColors.gold
                                                : AppColors.muted,
                                            fontWeight:
                                                FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isUploading)
                                  Text(
                                    _uploadedFileName != null
                                        ? 'Change'
                                        : 'Add ＋',
                                    style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.cocoa),
                                  ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── AI indicator
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.58),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.22)),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.sm,
                        ),
                        child: Row(children: [
                          const AntennaPulse(size: 8),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI analyzing your subject scope',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.cocoaDeep)),
                              Text(
                                  'RAG engine preparing contextual breakdown…',
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 10,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w300)),
                            ],
                          ),
                        ]),
                      ),
                    ),

                    // ── Generate button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 8),
                      child: AppButton(
                        label: 'Generate My Study Plan ✦',
                        gradient: AppGradients.ctaButtonFinal,
                        onTap: _generate,
                      ),
                    ),

                    // ── View Progress
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(26, 0, 26, 20),
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/progress'),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: AppColors.cocoa
                                .withValues(alpha: 0.08),
                            border: Border.all(
                                color: AppColors.cocoa
                                    .withValues(alpha: 0.22),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'View Progress',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoa,
                                  letterSpacing: 0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Days input ────────────────────────────────────────────────
class _DaysInput extends StatelessWidget {
  final TextEditingController controller;
  const _DaysInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.52),
        border: Border.all(
            color: const Color(0xFFB48C50).withOpacity(0.15), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.sm,
      ),
      child: Row(children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Study Duration',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cocoaDeep)),
              Text('Number of days',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        Container(
          width: 80,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: AppGradients.ctaButton,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                  color: AppColors.cocoaDeep.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const Text(' d',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Option row ────────────────────────────────────────────────
class _OptionRow extends StatelessWidget {
  final String title, sub;
  final List<String> options;
  final int selected;
  final void Function(int) onSelect;
  const _OptionRow({
    required this.title,
    required this.sub,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.52),
          border: Border.all(
              color: const Color(0xFFB48C50).withOpacity(0.15),
              width: 1.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.sm,
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                Text(sub,
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w300)),
              ],
            ),
          ),
          Row(
            children: options
                .asMap()
                .map((i, label) => MapEntry(
                      i,
                      GestureDetector(
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: EdgeInsets.only(left: i > 0 ? 5 : 0),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: i == selected
                                  ? AppGradients.ctaButton
                                  : null,
                              color: i == selected
                                  ? null
                                  : AppColors.cocoa.withOpacity(0.1),
                              border: Border.all(
                                  color: i == selected
                                      ? Colors.transparent
                                      : AppColors.cocoa
                                          .withOpacity(0.18)),
                              borderRadius:
                                  BorderRadius.circular(100),
                              boxShadow: i == selected
                                  ? [
                                      BoxShadow(
                                          color: AppColors.cocoaDeep
                                              .withOpacity(0.22),
                                          blurRadius: 12,
                                          offset:
                                              const Offset(0, 4))
                                    ]
                                  : null,
                            ),
                            child: Text(label,
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: i == selected
                                        ? AppColors.white
                                        : AppColors.cocoa)),
                          ),
                        ),
                      ),
                    ))
                .values
                .toList(),
          ),
        ]),
      );
}

// ─── Dashed border ─────────────────────────────────────────────
class _DashedBorder extends StatelessWidget {
  final Color color;
  final double borderRadius;
  final Widget child;
  const _DashedBorder(
      {required this.color,
      required this.borderRadius,
      required this.child});

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _DashPainter(color: color, radius: borderRadius),
      child: child);
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius));
    const dash = 6.0, gap = 4.0;
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    double dist = 0;
    bool draw = true;
    while (dist < metric.length) {
      final seg = draw ? dash : gap;
      if (draw) canvas.drawPath(metric.extractPath(dist, dist + seg), paint);
      dist += seg;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
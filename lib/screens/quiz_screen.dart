// ============================================================
// Page 18 — Quiz Question View
// ============================================================
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selected = -1; // -1 = none
  int _question = 3;
  static const _total = 10;

  static const _options = [
    'SN2 — Bimolecular nucleophilic substitution',
    'SN1 — Unimolecular nucleophilic substitution',
    'E2 — Bimolecular elimination',
    'E1cb — Carbanion mechanism',
  ];

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFFFDFAF4), Color(0xFFF4E8D6), Color(0xFFECDAC0)])),
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
                          radius: 0.68)))),
          SafeArea(
              child: Column(children: [
            // Nav
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
              child: Row(children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16)),
                        boxShadow: AppShadows.sm),
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                            child: Text('✕',
                                style: TextStyle(fontSize: 14, color: AppColors.cocoa))))),
                const Spacer(),
                const Text('Quiz · Organic Chemistry',
                    style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoaDeep)),
                const Spacer(),
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16)),
                        boxShadow: AppShadows.sm),
                    child: const Center(
                        child: Text('⋯', style: TextStyle(fontSize: 13, color: AppColors.cocoa)))),
              ]),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
              child: Stack(children: [
                Container(
                    height: 3,
                    decoration: BoxDecoration(
                        color: AppColors.cocoa.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2))),
                FractionallySizedBox(
                    widthFactor: _question / _total,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(children: [
                          Container(
                              height: 3,
                              decoration: const BoxDecoration(gradient: AppGradients.progress)),
                          ShimmerOverlay(duration: const Duration(milliseconds: 2000)),
                        ]))),
              ]),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(26, 5, 26, 0),
                child: Text('Question $_question of $_total · ${_total - _question} remaining',
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.06 * 11))),

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
                        boxShadow: AppShadows.md),
                    child: Stack(children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Container(
                                  height: 3,
                                  decoration:
                                      const BoxDecoration(gradient: AppGradients.progress)))),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('MULTIPLE CHOICE · CHAPTER 9',
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.14 * 9.5,
                                  color: AppColors.muted)),
                          const SizedBox(height: 8),
                          const Text(
                              'Which mechanism proceeds through a carbocation intermediate and follows first-order kinetics?',
                              style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoaDeep,
                                  letterSpacing: -0.01 * 15,
                                  height: 1.4)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Text('📄 ', style: TextStyle(fontSize: 12)),
                            const Text('From: Organic Chemistry Notes — Ch.9.pdf',
                                style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 10.5,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w300)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                ),

                // Options
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                  child: Column(
                      children: List.generate(4, (i) {
                    final letters = ['A', 'B', 'C', 'D'];
                    final sel = _selected == i;
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < 3 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.cocoa.withOpacity(0.06)
                                  : Colors.white.withOpacity(0.6),
                              border: Border.all(
                                  color: sel
                                      ? AppColors.cocoa
                                      : const Color(0xFFB48C50).withOpacity(0.14),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                          color: AppColors.cocoa.withOpacity(0.09),
                                          blurRadius: 0,
                                          spreadRadius: 3),
                                      ...AppShadows.sm
                                    ]
                                  : AppShadows.sm),
                          child: Row(children: [
                            AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                    gradient: sel ? AppGradients.ctaButton : null,
                                    color: sel ? null : AppColors.cocoa.withOpacity(0.08),
                                    border: Border.all(
                                        color: sel
                                            ? Colors.transparent
                                            : AppColors.cocoa.withOpacity(0.18)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(letters[i],
                                        style: TextStyle(
                                            fontFamily: 'Syne',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: sel ? AppColors.white : AppColors.cocoa)))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(_options[i],
                                    style: const TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.cocoaDeep,
                                        height: 1.4))),
                          ]),
                        ),
                      ),
                    );
                  })),
                ),
              ]),
            )),

            // Bottom nav
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 20),
              child: Row(children: [
                GestureDetector(
                    onTap: () => setState(() {
                          if (_question > 1) _question--;
                        }),
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.62),
                            border: Border.all(
                                color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.sm),
                        child: const Text('← Prev',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cocoa)))),
                const Spacer(),
                // Dots
                Row(
                    children: List.generate(5, (i) {
                  final active = i == 2;
                  return Padding(
                      padding: EdgeInsets.only(right: i < 4 ? 5 : 0),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 14 : 5,
                          height: 5,
                          decoration: BoxDecoration(
                              color: active
                                  ? AppColors.gold
                                  : AppColors.cocoa.withOpacity(i < 2 ? 1 : 0.18),
                              borderRadius: BorderRadius.circular(active ? 3 : 100))));
                })),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      if (_question < _total) {
                        setState(() => _question++);
                      } else {
                        Navigator.pushNamed(context, '/quiz-result');
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                        decoration: BoxDecoration(
                            gradient: AppGradients.ctaButton,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.btn),
                        child: const Text('Next →',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white)))),
              ]),
            ),
          ])),
        ]),
      ),
    );
  }
}

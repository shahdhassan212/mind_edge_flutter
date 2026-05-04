// ============================================================
// Page 14 — AI Result: Document Analysis
// ============================================================
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/common_widgets.dart';

class AiResultScreen extends StatefulWidget {
  const AiResultScreen({super.key});
  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  int _tab = 0;

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
                stops: [0.0, 0.45, 1.0],
                colors: [Color(0xFFFDFAF4), Color(0xFFF5EBDA), Color(0xFFECDCBF)])),
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
                const AppBackButton(),
                const Spacer(),
                const Text('AI Analysis',
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
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.16)),
                        boxShadow: AppShadows.sm),
                    child: const Center(
                        child: Text('↑', style: TextStyle(fontSize: 14, color: AppColors.cocoa)))),
              ]),
            ),

            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(children: [
                // Header card
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    decoration: BoxDecoration(
                      gradient: AppGradients.ctaButton,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.lg,
                    ),
                    child: Stack(children: [
                      Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: AppColors.gold.withOpacity(0.1)))),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('📄 Organic Chemistry Notes.pdf',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldLight.withOpacity(0.6),
                                letterSpacing: 0.14 * 10)),
                        const SizedBox(height: 5),
                        const Text('Analysis Complete',
                            style: TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                letterSpacing: -0.02 * 17,
                                height: 1.25)),
                        const SizedBox(height: 10),
                        Row(children: [
                          _Pill(label: '✦ 98.4% accuracy', style: _PillStyle.gold),
                          const SizedBox(width: 8),
                          _Pill(label: '847 words', style: _PillStyle.ghost),
                        ]),
                      ]),
                    ]),
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: AppColors.cocoa.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                        children: ['Summary', 'Bullets', 'Key Terms']
                            .asMap()
                            .map((i, label) {
                              final on = i == _tab;
                              return MapEntry(
                                  i,
                                  Expanded(
                                      child: GestureDetector(
                                    onTap: () => setState(() => _tab = i),
                                    child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                            gradient: on ? AppGradients.ctaButton : null,
                                            borderRadius: BorderRadius.circular(9)),
                                        child: Text(label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 10.5,
                                                fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                                                color: on ? AppColors.white : AppColors.muted))),
                                  )));
                            })
                            .values
                            .toList()),
                  ),
                ),

                // Content card
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.58),
                        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.14)),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.sm),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('AI SUMMARY',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.12 * 10,
                                color: AppColors.muted)),
                        const Spacer(),
                        // Speaker — placeholder for future Text-to-Audio
                        GestureDetector(
                          onTap: () {}, // TTS integration placeholder
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.cocoa.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: AppColors.cocoa.withOpacity(0.20)),
                            ),
                            child: const Icon(Icons.volume_up_outlined,
                                size: 14, color: AppColors.cocoa),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text.rich(TextSpan(
                          text: 'This document covers ',
                          style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.5,
                              color: Color(0xFF6B4C3B),
                              fontWeight: FontWeight.w300,
                              height: 1.65),
                          children: const [
                            TextSpan(
                                text: 'nucleophilic substitution reactions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: AppColors.cocoaDeep)),
                            TextSpan(
                                text:
                                    ', including SN1 and SN2 mechanisms. Key topics include carbocation stability, stereochemical outcomes, and the role of solvent polarity in determining reaction pathway…'),
                          ])),
                    ]),
                  ),
                ),

                // Topics
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('TOPICS IDENTIFIED',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.12 * 10.5,
                            color: AppColors.muted)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _TopicPill('SN1 Mechanism', _PillStyle.cocoa),
                      _TopicPill('SN2 Mechanism', _PillStyle.cocoa),
                      _TopicPill('Carbocations', _PillStyle.gold),
                      _TopicPill('Stereochemistry', _PillStyle.ghost),
                    ]),
                  ]),
                ),

                // CTAs
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                  child: Row(children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/quiz'),
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.62),
                              border: Border.all(
                                  color: const Color(0xFFB48C50).withOpacity(0.18), width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.sm),
                          child: const Text('Generate Quiz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoa))),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/study-plan'),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                  gradient: AppGradients.ctaButton,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppShadows.btn),
                              child: const Text('Add to Study Plan ✦',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white))),
                        )),
                  ]),
                ),
              ]),
            )),
          ])),
        ]),
      ),
    );
  }
}

enum _PillStyle { gold, ghost, cocoa }

class _Pill extends StatelessWidget {
  final String label;
  final _PillStyle style;
  const _Pill({required this.label, required this.style});
  @override
  Widget build(BuildContext context) {
    final isGold = style == _PillStyle.gold;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
            color: isGold ? AppColors.gold.withOpacity(0.18) : Colors.white.withOpacity(0.1),
            border: Border.all(
                color: isGold ? AppColors.gold.withOpacity(0.28) : Colors.white.withOpacity(0.16)),
            borderRadius: BorderRadius.circular(100)),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isGold ? AppColors.goldLight : AppColors.white.withOpacity(0.7))));
  }
}

class _TopicPill extends StatelessWidget {
  final String label;
  final _PillStyle style;
  const _TopicPill(this.label, this.style);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: style == _PillStyle.gold
                ? AppColors.gold.withOpacity(0.12)
                : AppColors.cocoa.withOpacity(0.1),
            border: Border.all(
                color: style == _PillStyle.gold
                    ? AppColors.gold.withOpacity(0.22)
                    : AppColors.cocoa.withOpacity(0.18)),
            borderRadius: BorderRadius.circular(100)),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: style == _PillStyle.gold ? const Color(0xFF7A5A1A) : AppColors.cocoa)));
  }
}

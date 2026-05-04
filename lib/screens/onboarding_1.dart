// ============================================================
// Screen 02: Onboarding 1 — Scan & Understand Any Document
// ============================================================

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.onboarding1),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top bar
              Padding(
                padding: EdgeInsets.fromLTRB(28, isSmall ? 6 : 10, 28, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                          text: 'Mind',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.2)),
                      TextSpan(
                          text: 'Edge',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoa,
                              letterSpacing: -0.2)),
                    ])),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Skip',
                            style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Illustration
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 56).clamp(180.0, 240.0);
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Main card
                          _ObCard1(width: cardW),

                          // OCR Active badge — top right
                          Positioned(
                            top: -16,
                            right: (constraints.maxWidth - cardW) / 2 - 50,
                            child: FloatWidget(
                              duration: AppDuration.floatA,
                              delay: const Duration(milliseconds: 300),
                              translateYMax: -5,
                              child: FloatingBadge(
                                label: '🔍 OCR Active',
                                showLiveDot: true,
                                // التعديل هنا: هنمرر الـ decoration للـ Widget مباشرة
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      // استخدمت لون أسود بـ opacity لأن الـ _c مش متعرفة
                                      color: const Color(0xFF000000).withOpacity(0.32),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 98% Accuracy badge — bottom left
                          Positioned(
                            bottom: -10,
                            left: (constraints.maxWidth - cardW) / 2 - 50,
                            child: FloatWidget(
                              duration: AppDuration.floatB,
                              delay: const Duration(milliseconds: 600),
                              translateYMax: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  // التعديل: التدرج اللوني المرجعي (البيج للبني)
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      // التعديل: الظل الموحد مع opacity 0.32
                                      color: const Color(0xFF000000).withOpacity(0.32),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '✦',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.white, // خليتها أبيض عشان تنطق مع التدرج الجديد
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '98% Accuracy',
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600, // خليتها w600 زي الزرار المرجعي
                                        color: Colors.white, // اللون الأبيض الموحد
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // ── Bottom content
              Container(
                padding: EdgeInsets.fromLTRB(28, 0, 28, isSmall ? 20 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OnboardingDots(total: 3, active: 0),
                    SizedBox(height: isSmall ? 10 : 16),
                    RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                          text: 'Scan & ',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.5,
                              height: 1.2)),
                      TextSpan(
                          text: 'Understand',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoa,
                              letterSpacing: -0.5,
                              height: 1.2)),
                      TextSpan(
                          text: ' Any\nDocument',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.5,
                              height: 1.2)),
                    ])),
                    SizedBox(height: isSmall ? 6 : 10),
                    const Text(
                        'Upload or scan handwritten notes, PDFs, and textbooks. Our AI extracts and structures everything instantly.',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.5,
                            color: Color(0xFF6B4C3B),
                            fontWeight: FontWeight.w300,
                            height: 1.6)),
                    SizedBox(height: isSmall ? 14 : 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.32),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: PrimaryButton(
                        label: 'Continue →',
                        onTap: () => Navigator.pushNamed(context, '/onboarding2'),
                        shimmerDelay: const Duration(seconds: 2),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ILLUSTRATION CARD
// ─────────────────────────────────────────────────────────────
class _ObCard1 extends StatelessWidget {
  final double width;
  const _ObCard1({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF502D14).withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(children: [
          // Top accent bar
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                      gradient: AppGradients.cardTopAccent,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24))))),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // PDF document icon
              Center(child: _PdfDocIcon()),
              const SizedBox(height: 14),
              const Text('Scan any document',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w300,
                      height: 1.5),
                  textAlign: TextAlign.center),
            ]),
          ),

          // Scan beam animation
          const Positioned.fill(
            child: ScanBeamWidget(),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PDF DOCUMENT ICON
// ─────────────────────────────────────────────────────────────
class _PdfDocIcon extends StatelessWidget {
  const _PdfDocIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF502D14).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF label
          Text('PDF',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          // Text lines
          ..._lines(),
        ],
      ),
    );
  }

  List<Widget> _lines() {
    final widths = [1.0, 0.85, 0.7, 0.9, 0.6];
    return widths
        .map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: FractionallySizedBox(
                widthFactor: w,
                alignment: Alignment.centerLeft,
                child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cocoa.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2))),
              ),
            ))
        .toList();
  }
}

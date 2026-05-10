// screens/onboarding_1.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/onboarding_helpers.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.onboarding1),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ObTopBar(isSmall: isSmall),

              // ── Illustration
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 56).clamp(180.0, 240.0);
                  final offset = (constraints.maxWidth - cardW) / 2 - 50;
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _ObCard1(width: cardW),
                          Positioned(
                            top: -16,
                            right: offset,
                            child: FloatWidget(
                              duration: AppDuration.floatA,
                              delay: const Duration(milliseconds: 300),
                              translateYMax: -5,
                              child: const FloatingBadge(
                                label: '🔍 OCR Active',
                                showLiveDot: true,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: offset,
                            child: FloatWidget(
                              duration: AppDuration.floatB,
                              delay: const Duration(milliseconds: 600),
                              translateYMax: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.badge,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x52000000),
                                        blurRadius: 24,
                                        offset: Offset(0, 8))
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('✦', style: TextStyle(fontSize: 11, color: Colors.white)),
                                    SizedBox(width: 5),
                                    Text('98% Accuracy',
                                        style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
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
              Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, isSmall ? 20 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OnboardingDots(total: 3, active: 0),
                    SizedBox(height: isSmall ? 10 : 16),
                    ObTitle(
                      parts: const [
                        ('Scan & ', true),
                        ('Understand', false),
                        (' Any\nDocument', true),
                      ],
                    ),
                    SizedBox(height: isSmall ? 6 : 10),
                    const ObBody(
                      'Upload or scan handwritten notes, PDFs, and textbooks. '
                      'Our AI extracts and structures everything instantly.',
                    ),
                    SizedBox(height: isSmall ? 14 : 20),
                    AppButton(
                      label: 'Continue →',
                      onTap: () => Navigator.pushNamed(context, '/onboarding2'),
                    ),
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

// ─── Illustration card ─────────────────────────────────────────
class _ObCard1 extends StatelessWidget {
  final double width;
  const _ObCard1({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(AppRadius.obCard),
        border: Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF502D14).withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.obCard),
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: AppGradients.cardTopAccent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Center(child: _PdfDocIcon()),
              const SizedBox(height: 14),
              const Text(
                'Scan any document',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w300,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          const Positioned.fill(child: ScanBeamWidget()),
        ]),
      ),
    );
  }
}

class _PdfDocIcon extends StatelessWidget {
  const _PdfDocIcon();

  static const _widths = [1.0, 0.85, 0.7, 0.9, 0.6];

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
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PDF',
              style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          ..._widths.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: FractionallySizedBox(
                  widthFactor: w,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.cocoa.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

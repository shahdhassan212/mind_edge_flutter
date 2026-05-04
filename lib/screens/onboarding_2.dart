// ============================================================
// Screen 03: Onboarding 2 — AI Audio Lectures — Fixed
// ============================================================

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.onboarding2),
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
                                  fontFamily: 'DM Sans', fontSize: 13, color: AppColors.muted))),
                    ),
                  ],
                ),
              ),

              // ── Illustration
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 56).clamp(180.0, 240.0);
                  final waveW = cardW - 44;
                  final padLeft = (constraints.maxWidth - cardW) / 2;

                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _ObCard2(cardWidth: cardW, waveformWidth: waveW),
                          Positioned(
                            bottom: -10,
                            right: padLeft - 16,
                            child: FloatWidget(
                              duration: AppDuration.floatC,
                              delay: const Duration(milliseconds: 500),
                              translateYMax: 3,
                              child: FloatingBadge(
                                label: '▶ Playing',
                                showLiveDot: true,
                                // التعديل هنا: بنبعت الـ decoration اللي الـ Widget مستنياه
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF000000).withOpacity(0.32),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: -10,
                              right: padLeft - 16,
                              child: FloatWidget(
                                  duration: AppDuration.floatC,
                                  delay: const Duration(milliseconds: 500),
                                  translateYMin: -2,
                                  translateYMax: 3,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                    decoration: BoxDecoration(
                                        gradient: AppGradients.badge,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Color(0x474E3228),
                                              blurRadius: 24,
                                              offset: Offset(0, 8))
                                        ]),
                                    child: const Text('1.5× Speed',
                                        style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 10.5,
                                            color: AppColors.goldLight,
                                            fontWeight: FontWeight.w500)),
                                  ))),
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
                    const OnboardingDots(total: 3, active: 1),
                    SizedBox(height: isSmall ? 10 : 16),
                    RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                          text: 'AI Audio\n',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.5,
                              height: 1.2)),
                      TextSpan(
                          text: 'Lectures',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoa,
                              letterSpacing: -0.5,
                              height: 1.2)),
                    ])),
                    SizedBox(height: isSmall ? 6 : 10),
                    const Text(
                        'Transform any document into rich audio lectures. Learn hands-free while commuting, exercising, or relaxing.',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.5,
                            color: Color(0xFF6B4C3B),
                            fontWeight: FontWeight.w300,
                            height: 1.6)),
                    SizedBox(height: isSmall ? 14 : 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/onboarding3'),
                      child: Container(
                        width: double.infinity, // عشان ياخد العرض المتاح
                        height: 56, // الارتفاع المعتاد للزراير الأساسية
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                        child: const Center(
                          child: Text(
                            'Next →',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans', // حسب الفونت المستخدم عندك
                            ),
                          ),
                        ),
                      ),
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

class _ObCard2 extends StatelessWidget {
  final double cardWidth;
  final double waveformWidth;
  const _ObCard2({required this.cardWidth, required this.waveformWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              height: 3, decoration: const BoxDecoration(gradient: AppGradients.cardTopAccent)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              RepaintBoundary(
                child: SizedBox(
                  width: waveformWidth, // Control width from here
                  child: WaveformWidget(
                    barCount: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                    height: 3,
                    child: Stack(children: [
                      Container(color: AppColors.cocoa.withOpacity(0.12)),
                      FractionallySizedBox(
                          widthFactor: 0.45,
                          alignment: Alignment.centerLeft,
                          child: Container(
                              decoration: const BoxDecoration(gradient: AppGradients.loader))),
                    ])),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('2:34',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.cocoa,
                        fontWeight: FontWeight.w500)),
                Text('5:48',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        color: AppColors.muted.withOpacity(0.5),
                        fontWeight: FontWeight.w300)),
              ]),
              const SizedBox(height: 10),
              const Text('Chapter 3: Neural Networks',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }
}

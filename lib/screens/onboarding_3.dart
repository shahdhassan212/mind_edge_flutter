// ============================================================
// Screen 04: Onboarding 3 — Your AI Study Assistant — Fixed
// ============================================================

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../animations/animation_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/robot_widget.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4E8),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.onboarding3),
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
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const _ObCard3(),
                        Positioned(
                            top: -20,
                            right: 0,
                            child: FloatWidget(
                                duration: AppDuration.floatA,
                                delay: const Duration(milliseconds: 300),
                                translateYMax: -6,
                                rotateMin: -1,
                                rotateMax: 1,
                                child: const CompanionBot(size: 34, opacity: 0.7))),
                        Positioned(
                            bottom: -12,
                            left: 0,
                            child: FloatWidget(
                                duration: AppDuration.floatD,
                                delay: const Duration(milliseconds: 700),
                                translateYMin: 2,
                                translateYMax: -5,
                                child: const CompanionBot(size: 28, opacity: 0.55))),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom content
              Container(
                padding: EdgeInsets.fromLTRB(28, 0, 28, isSmall ? 20 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OnboardingDots(total: 3, active: 2),
                    SizedBox(height: isSmall ? 10 : 16),
                    RichText(
                        text: const TextSpan(children: [
                      TextSpan(
                          text: 'Your AI\n',
                          style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cocoaDeep,
                              letterSpacing: -0.5,
                              height: 1.2)),
                      TextSpan(
                          text: 'Study Assistant',
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
                        'Ask questions, generate summaries, create flashcards and quizzes. Your personal AI tutor is always available.',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.5,
                            color: Color(0xFF6B4C3B),
                            fontWeight: FontWeight.w300,
                            height: 1.6)),
                    SizedBox(height: isSmall ? 14 : 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // التدرج المعتمد: من البيج/الذهبي للبني
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
                            'Get Started →',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
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

class _ObCard3 extends StatelessWidget {
  const _ObCard3();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FloatWidget(
                  duration: AppDuration.floatMain,
                  translateYMax: -5,
                  child: const CompanionBot(size: 48)),
              const SizedBox(height: 12),
              _ChatBubble(text: 'Explain quantum entanglement in simple terms.', isUser: true),
              const SizedBox(height: 6),
              _ChatBubble(
                  text:
                      'Think of it as two particles that are "linked" — when you measure one, you instantly know the state of the other.',
                  isUser: false),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 165),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.cocoa.withOpacity(0.10) : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cocoa.withOpacity(isUser ? 0.18 : 0.09)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 9.5,
                color: AppColors.cocoaDark,
                fontWeight: FontWeight.w300,
                height: 1.5)),
      ),
    );
  }
}

// screens/onboarding_3.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/onboarding_helpers.dart';
import '../widgets/robot_widget.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.onboarding3),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ObTopBar(isSmall: isSmall),

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
                            child: const CompanionBot(size: 34, opacity: 0.7),
                          ),
                        ),
                        Positioned(
                          bottom: -12,
                          left: 0,
                          child: FloatWidget(
                            duration: AppDuration.floatD,
                            delay: const Duration(milliseconds: 700),
                            translateYMin: 2,
                            translateYMax: -5,
                            child: const CompanionBot(size: 28, opacity: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom content
              Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, isSmall ? 20 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OnboardingDots(total: 3, active: 2),
                    SizedBox(height: isSmall ? 10 : 16),
                    ObTitle(
                      parts: const [
                        ('Your AI\n', true),
                        ('Study Assistant', false),
                      ],
                    ),
                    SizedBox(height: isSmall ? 6 : 10),
                    const ObBody(
                      'Ask questions, generate summaries, create flashcards and quizzes. '
                      'Your personal AI tutor is always available.',
                    ),
                    SizedBox(height: isSmall ? 14 : 20),
                    AppButton(
                      label: 'Get Started →',
                      onTap: () => Navigator.pushNamed(context, '/signup'),
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
        borderRadius: BorderRadius.circular(AppRadius.obCard),
        border:
            Border.all(color: const Color(0xFFB48C50).withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF502D14).withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.obCard),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              height: 3,
              decoration:
                  const BoxDecoration(gradient: AppGradients.cardTopAccent)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FloatWidget(
                duration: AppDuration.floatMain,
                translateYMax: -5,
                child: const CompanionBot(size: 48),
              ),
              const SizedBox(height: 12),
              const _ChatBubble(
                  text: 'Explain quantum entanglement in simple terms.',
                  isUser: true),
              const SizedBox(height: 6),
              const _ChatBubble(
                text:
                    'Think of it as two particles that are "linked" — when you measure one, '
                    'you instantly know the state of the other.',
                isUser: false,
              ),
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
          color: isUser
              ? AppColors.cocoa.withOpacity(0.10)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.cocoa.withOpacity(isUser ? 0.18 : 0.09)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 9.5,
              color: AppColors.cocoaDark,
              fontWeight: FontWeight.w300,
              height: 1.5),
        ),
      ),
    );
  }
}
// screens/forgot_password_success.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/common_widgets.dart';

class ForgotPasswordSuccessScreen extends StatelessWidget {
  const ForgotPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDFAF4), Color(0xFFF5EBD6)])),
        child: Stack(children: [
          AppDecorOrb(top: -60, right: -60, size: 280, color: AppColors.gold.withOpacity(0.12)),
          AppDecorOrb(bottom: -80, left: -80, size: 260, color: AppColors.cocoa.withOpacity(0.08)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeUpEntrance(
                  delay: Duration.zero,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.gold.withOpacity(0.14),
                          AppColors.cocoa.withOpacity(0.07),
                        ]),
                        border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.gold.withOpacity(0.06),
                              blurRadius: 0,
                              spreadRadius: 14),
                          BoxShadow(
                              color: const Color(0xFF643C14).withOpacity(0.12),
                              blurRadius: 40,
                              offset: const Offset(0, 16)),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(size: const Size(38, 38), painter: _CheckPainter()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 150),
                  child: const Text('Password updated\nsuccessfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cocoaDeep,
                          letterSpacing: -0.6,
                          height: 1.2)),
                ),
                const SizedBox(height: 10),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 250),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Your account is secure. Sign in with your new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w300,
                            height: 1.65)),
                  ),
                ),
                const SizedBox(height: 32),
                FadeUpEntrance(
                  delay: const Duration(milliseconds: 350),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AppButton(
                      label: 'Continue to Sign In',
                      gradient: AppGradients.ctaButtonFinal,
                      onTap: () =>
                          Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cocoa
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.53)
      ..lineTo(size.width * 0.42, size.height * 0.71)
      ..lineTo(size.width * 0.76, size.height * 0.34);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

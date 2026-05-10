// screens/splash_screen.dart — with real session check
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../widgets/animation_helpers.dart';
import '../widgets/robot_widget.dart';
import '../core/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _loaderCtrl;
  late Animation<double> _loaderWidth;

  @override
  void initState() {
    super.initState();
    _loaderCtrl = AnimationController(vsync: this, duration: AppDuration.loaderFill);
    _loaderWidth = CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut);
    _loaderCtrl.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 4500));
    if (!mounted) return;
    final hasSession = await TokenStorage.instance.hasValidToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, hasSession ? '/dashboard' : '/onboarding1');
  }

  @override
  void dispose() {
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: Stack(fit: StackFit.expand, children: [
        Container(decoration: const BoxDecoration(gradient: AppGradients.splash)),

        Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
                child: Container(
                    width: size.width * 1.2,
                    height: size.height * 0.35,
                    decoration: BoxDecoration(
                        gradient: RadialGradient(
                            center: const Alignment(0, -1),
                            radius: 1.0,
                            colors: [
                          Colors.white.withOpacity(0.9),
                          const Color(0xFFFAF4E8).withOpacity(0.4),
                          Colors.transparent
                        ],
                            stops: const [
                          0.0,
                          0.5,
                          1.0
                        ]))))),

        Positioned.fill(
            child: Center(
                child: AmbientRotate(
                    child: Container(
                        width: size.width * 1.4,
                        height: size.width * 1.4,
                        decoration: BoxDecoration(
                            gradient: SweepGradient(colors: [
                              const Color(0xFFB4823C).withOpacity(0.0),
                              const Color(0xFFB4823C).withOpacity(0.06),
                              const Color(0xFFB4823C).withOpacity(0.0),
                              const Color(0xFFB4823C).withOpacity(0.03),
                              const Color(0xFFB4823C).withOpacity(0.0)
                            ]),
                            shape: BoxShape.circle))))),

        // Halo rings
        Positioned(
            top: size.height * 0.22,
            left: size.width * 0.5 - 110,
            child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFB4823C).withOpacity(0.70))))),
        Positioned(
            top: size.height * 0.22 - 50,
            left: size.width * 0.5 - 160,
            child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB4823C).withOpacity(0.055))))),

        // Companion bots
        Positioned(
            top: size.height * 0.14,
            left: 8,
            child: FloatWidget(
                duration: AppDuration.floatA,
                delay: const Duration(milliseconds: 400),
                translateYMin: 0,
                translateYMax: -7,
                rotateMin: -1.0,
                rotateMax: 1.0,
                child: const CompanionBot(size: 30, opacity: 0.55))),
        Positioned(
            top: size.height * 0.12,
            right: 6,
            child: FloatWidget(
                duration: AppDuration.floatB,
                delay: const Duration(milliseconds: 800),
                translateYMin: 0,
                translateYMax: -5,
                rotateMin: 1.0,
                rotateMax: -1.5,
                child: const CompanionBot(size: 34, opacity: 0.65))),
        Positioned(
            top: size.height * 0.28,
            right: 4,
            child: FloatWidget(
                duration: AppDuration.floatC,
                delay: const Duration(milliseconds: 1200),
                translateYMin: -3,
                translateYMax: 4,
                child: const CompanionBot(size: 28, opacity: 0.45))),
        Positioned(
            top: size.height * 0.30,
            left: 4,
            child: FloatWidget(
                duration: AppDuration.floatD,
                delay: const Duration(milliseconds: 200),
                translateYMin: 2,
                translateYMax: -6,
                child: const CompanionBot(size: 30, opacity: 0.5))),

        SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: isSmall ? 24 : 36),

          // Logo
          FadeUpEntrance(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 900),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: 'Mind',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cocoaDeep,
                          letterSpacing: -0.8)),
                  TextSpan(
                      text: 'Edge',
                      style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cocoa,
                          letterSpacing: -0.8)),
                ])),
                const SizedBox(height: 4),
                const Text('your mind, sharpened',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: AppColors.muted,
                        letterSpacing: 1.5)),
              ])),

          // Robot
          Expanded(
              child: FadeUpEntrance(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 1000),
                  child: Center(
                      child: FloatWidget(
                          duration: AppDuration.floatMain,
                          translateYMin: 0,
                          translateYMax: -10,
                          rotateMin: 0,
                          rotateMax: 0.4,
                          child: Transform.scale(
                              scale: isSmall ? 1.1 : 1.3, child: const MainRobot()))))),

          // Book
          FadeUpEntrance(
              delay: const Duration(milliseconds: 700),
              duration: const Duration(milliseconds: 1100),
              child: SizedBox(
                  height: 80,
                  child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                    Positioned(bottom: 0, child: GlowPulse(width: 160, height: 44)),
                    const Positioned(top: 0, child: BookWidget()),
                  ]))),

          SizedBox(height: isSmall ? 8 : 16),

          // Loader bar
          FadeUpEntrance(
              delay: const Duration(milliseconds: 1000),
              child: Padding(
                  padding: EdgeInsets.only(bottom: isSmall ? 24 : 40),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                        width: 90,
                        height: 3,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Stack(children: [
                              const ColoredBox(color: Color(0x28A06432), child: SizedBox.expand()),
                              AnimatedBuilder(
                                  animation: _loaderWidth,
                                  builder: (_, __) => FractionallySizedBox(
                                      widthFactor: _loaderWidth.value,
                                      alignment: Alignment.centerLeft,
                                      child: Stack(children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFC9A96E), Color(0xFF7C5642)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          ),
                                          child: const SizedBox.expand(),
                                        ),
                                        ShimmerOverlay(
                                            duration: const Duration(milliseconds: 1600),
                                            delay: Duration.zero,
                                            shimmerOpacity: 0.5),
                                      ]))),
                            ]))),
                    const SizedBox(height: 10),
                    const Text('INITIALIZING AI ENGINE',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: AppColors.muted,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w400)),
                  ]))),
        ])),
      ]),
    );
  }
}

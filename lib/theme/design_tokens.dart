// ============================================================
// MindEdge Design Tokens v3.0
// Single source of truth for all design values
// ============================================================

import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFAF6EE);
  static const Color beige = Color(0xFFEDE3D0);
  static const Color tan = Color(0xFFD4B896);
  static const Color gold = Color(0xFFC9A96E);
  static const Color goldLight = Color(0xFFE8D5A8);
  static const Color cocoa = Color(0xFF7C5642);
  static const Color cocoaDark = Color(0xFF4A3228);
  static const Color cocoaDeep = Color(0xFF2E1E17);
  static const Color muted = Color(0xFFA08070);
  static const Color robotBody = Color(0xFF9A7060);
  static const Color bodyBg = Color(0xFF120D07);
  static const Color coffeeDeep = Color(0xFF4A3427);

  // Semantic surface
  static Color surface = Colors.white.withOpacity(0.72);
  static Color surfaceLight = Colors.white.withOpacity(0.58);

  // Text shades
  static const Color textBody = Color(0xFFF5EFE4);
  static Color text60 = const Color(0xFFF5EFE4).withOpacity(0.60);
  static Color text45 = const Color(0xFFF5EFE4).withOpacity(0.45);
  static Color text35 = const Color(0xFFF5EFE4).withOpacity(0.35);
  static Color text88 = const Color(0xFFF5EFE4).withOpacity(0.88);

  // Warm tinted shadow bases
  static const Color shadowWarm1 = Color(0xFF643C14); // rgba(100,60,20)
  static const Color shadowWarm2 = Color(0xFF502D14); // rgba(80,45,20)
  static const Color shadowWarm3 = Color(0xFF3C230F); // rgba(60,35,15)
  static const Color shadowBtn = Color(0xFF2E1E17); // rgba(46,30,23)
}

// ─── Gradients ────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.22, 0.50, 0.78, 1.0],
    colors: [
      Color(0xFFFDFAF4),
      Color(0xFFFAF4E8),
      Color(0xFFF5EBDA),
      Color(0xFFEDD8BF),
      Color(0xFFE2C9A2),
    ],
  );

  static const LinearGradient onboarding1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
    transform: GradientRotation(182 * 3.14159265358979 / 180),
    colors: [Color(0xFFFDFAF4), Color(0xFFF7EDDA), Color(0xFFEFE1C8)],
  );

  static const LinearGradient onboarding2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
    colors: [Color(0xFFFCF6EC), Color(0xFFF4E8D4), Color(0xFFEAD8BE)],
  );

  static const LinearGradient onboarding3 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.45, 1.0],
    colors: [Color(0xFFFDF8EE), Color(0xFFF5EBD8), Color(0xFFEADDC6)],
  );

  static const LinearGradient signIn = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.60, 1.0],
    colors: [Color(0xFFFDFAF4), Color(0xFFF7EDDA), Color(0xFFEFE0C8)],
  );

  static const LinearGradient signUp = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.50, 1.0],
    colors: [Color(0xFFFCF7EE), Color(0xFFF3E8D4), Color(0xFFEAD9BF)],
  );

  static const LinearGradient ctaButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [Color(0xFF321B10), AppColors.coffeeDeep],
  );

  static const LinearGradient ctaButtonFinal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [AppColors.gold, AppColors.cocoa],
  );

  static const LinearGradient badge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [AppColors.cocoa, AppColors.cocoaDark],
  );

  static const LinearGradient loader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.cocoa, AppColors.gold],
  );

  static const LinearGradient progress = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.cocoa, AppColors.gold],
  );

  static const LinearGradient waveBar = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [AppColors.cocoa, AppColors.gold],
  );

  static const LinearGradient cardTopAccent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.cocoa, AppColors.gold],
  );
}

// ─── Border Radius ────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double phoneShell = 48.0;
  static const double card = 22.0;
  static const double obCard = 24.0;
  static const double button = 16.0;
  static const double input = 14.0;
  static const double socialBtn = 14.0;
  static const double smallBtn = 12.0;
  static const double pill = 100.0;
  static const double badge = 16.0;
  static const double checkbox = 5.0;
}

// ─── Shadows ──────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppColors.shadowWarm1.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: AppColors.shadowWarm2.withOpacity(0.13),
          blurRadius: 36,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: AppColors.shadowWarm3.withOpacity(0.20),
          blurRadius: 60,
          offset: const Offset(0, 24),
        ),
      ];

  static List<BoxShadow> get btn => [
        BoxShadow(
          color: AppColors.shadowBtn.withOpacity(0.32),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get inputFocus => [
        BoxShadow(
          color: AppColors.cocoa.withOpacity(0.10),
          blurRadius: 0,
          spreadRadius: 3,
        ),
        ...sm,
      ];

  static List<BoxShadow> get phoneShell => [
        BoxShadow(
          color: AppColors.gold.withOpacity(0.08),
          blurRadius: 0,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.65),
          blurRadius: 96,
          offset: const Offset(0, 48),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];
}

// ─── Spacing ─────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s11 = 11.0;
  static const double s12 = 12.0;
  static const double s13 = 13.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s24 = 24.0;
  static const double s26 = 26.0;
  static const double s28 = 28.0;
  static const double s30 = 30.0;
  static const double s32 = 32.0;
  static const double s36 = 36.0;
  static const double s44 = 44.0;
  static const double s48 = 48.0;
  static const double s52 = 52.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s88 = 88.0;

  // Screen horizontal padding
  static const double screenH = 28.0;
  static const double authH = 30.0;
}

// ─── Typography sizes ─────────────────────────────────────────
class AppTextSize {
  AppTextSize._();

  static const double label = 10.0;
  static const double labelSm = 10.5;
  static const double caption = 11.0;
  static const double small = 11.5;
  static const double body = 12.5;
  static const double bodyMd = 13.0;
  static const double bodyLg = 13.5;
  static const double button = 14.0;
  static const double logo = 15.0;
  static const double obLogo = 15.0;
  static const double iconSm = 14.0;
  static const double icon = 15.0;
  static const double social = 12.0;
  static const double input = 13.5;
  static const double headline = 21.0;
  static const double authHead = 28.0;
  static const double splashLogo = 26.0;
}

// ─── Animation Durations ──────────────────────────────────────
class AppDuration {
  AppDuration._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration moderate = Duration(milliseconds: 500);
  static const Duration loaderFill = Duration(milliseconds: 3500);
  static const Duration shimmer = Duration(milliseconds: 1600);
  static const Duration shimmerBtn = Duration(milliseconds: 3500);
  static const Duration shimmerOb = Duration(milliseconds: 3000);
  static const Duration glowPulse = Duration(milliseconds: 2400);
  static const Duration floatMain = Duration(milliseconds: 4500);
  static const Duration floatA = Duration(milliseconds: 3800);
  static const Duration floatB = Duration(milliseconds: 4200);
  static const Duration floatC = Duration(milliseconds: 3500);
  static const Duration floatD = Duration(milliseconds: 4800);
  static const Duration pageFlip = Duration(milliseconds: 3600);
  static const Duration scan = Duration(milliseconds: 2200);
  static const Duration antennaPulse = Duration(milliseconds: 2000);
  static const Duration dotBreath = Duration(seconds: 2);
  static const Duration fadeUp = Duration(milliseconds: 900);
  static const Duration ambientRotate = Duration(seconds: 24);
  static const Duration blink = Duration(milliseconds: 3500);
}

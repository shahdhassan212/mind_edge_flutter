import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_1.dart';
import '../screens/onboarding_2.dart';
import '../screens/onboarding_3.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
import '../screens/verify_email_screen.dart';
import '../screens/forgot_password_email.dart';
import '../screens/forgot_password_code.dart';
import '../screens/forgot_password_newpass.dart';
import '../screens/forgot_password_success.dart';
import '../screens/dashboard_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/ocr_processing_screen.dart';
import '../screens/ai_result_screen.dart';
import '../screens/study_plan_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/audio_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/library_screen.dart';
import '../screens/ai_analysis_screen.dart';

class AppRouter {
  
  static const String initialRoute = '/';

  static Route<dynamic>? onGenerateRoute(RouteSettings s) {
    Widget? page;

    switch (s.name) {
      // ── Auth Flow
      case '/':
        page = const SplashScreen();
        break;
      case '/onboarding1':
        page = const OnboardingScreen1();
        break;
      case '/onboarding2':
        page = const OnboardingScreen2();
        break;
      case '/onboarding3':
        page = const OnboardingScreen3();
        break;
      case '/signin':
        page = const SignInScreen();
        break;
      case '/signup':
        page = const SignUpScreen();
        break;
      case '/verify-email':
        final email = s.arguments as String? ?? '';
        page = VerifyEmailScreen(email: email);
        break;

      // ── Forgot Password Flow
      case '/forgot-email':
        page = const ForgotPasswordEmailScreen();
        break;
      case '/forgot-code':
        final email = s.arguments as String? ?? '';
        page = ForgotPasswordCodeScreen(email: email);
        break;
      case '/forgot-newpass':
        final args = s.arguments as Map<String, String>? ?? {};
        page = ForgotPasswordNewPassScreen(
          email: args['email'] ?? '',
          code: args['code'] ?? '',
        );
        break;
      case '/forgot-success':
        page = const ForgotPasswordSuccessScreen();
        break;

      // ── Main App Features
      case '/dashboard':
        page = const DashboardScreen();
        break;
      case '/library':
        page = const LibraryScreen();
        break;
      case '/study-plan':
      case '/study_plan_screen':
        page = const StudyPlanScreen();
        break;
      case '/scan':
        page = const ScanScreen();
        break;
      case '/ai-analysis':
        final args = s.arguments;
        File? file;
        String? displayName;
        if (args is Map) {
          final filePath = args['filePath'] as String?;
          final fileName = args['fileName'] as String?;
          if (filePath != null && fileName != null && filePath.isNotEmpty) {
            file = File(filePath);
            displayName = fileName;
          }
        }
        page = AIAnalysisScreen(file: file, displayName: displayName);
        break;
      case '/audio':
      case '/audio_screen':
        page = const AudioScreen();
        break;
      case '/settings':
        page = const SettingsScreen();
        break;
      case '/ocr-processing':
        page = const OcrProcessingScreen();
        break;
      case '/ai-result':
        page = const AiResultScreen();
        break;
      case '/progress':
        page = const ProgressScreen();
        break;
      case '/quiz':
      case '/quiz_screen':
        page = const QuizScreen();
        break;
      case '/quiz-result':
        page = const QuizResultScreen();
        break;
      
      // حالة احتياطية لو المسار مش موجود
      default:
        page = null;
    }

    if (page == null) return null;

    return PageRouteBuilder(
      settings: s,
      pageBuilder: (context, animation, secondaryAnimation) => page!,
      transitionsBuilder: (context, anim, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: anim,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
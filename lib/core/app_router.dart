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
import '../screens/audio_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/library_screen.dart';
import '../screens/ai_analysis_screen.dart';
import '../screens/ai_chat_screen.dart'; // ← NEW

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic>? onGenerateRoute(RouteSettings s) {
    Widget? page;

    switch (s.name) {
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

      case '/dashboard':
        page = const DashboardScreen();
        break;
      case '/library':
        page = const LibraryScreen();
        break;
      case '/study-plan':
        page = const StudyPlanScreen();
        break;
      case '/scan':
        page = const ScanScreen();
        break;

      case '/ai-analysis':
        final raw = s.arguments;
        String? filePath;
        String? fileName;
        if (raw is Map<String, String?>) {
          filePath = raw['filePath'];
          fileName = raw['fileName'];
        } else if (raw is Map<String, dynamic>) {
          filePath = raw['filePath'] as String?;
          fileName = raw['fileName'] as String?;
        }
        page = AIAnalysisScreen(
          file: filePath != null ? File(filePath) : null,
          displayName: fileName ?? filePath?.split('/').last,
        );
        break;
      case '/ai-chat':
        final args = s.arguments as Map<String, dynamic>? ?? {};
        page = AIChatScreen(
          fileName: args['fileName'] as String? ?? '',
          sessionId: args['sessionId'] as String?,
        );
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
      case '/quiz':
        page = const QuizScreen();
        break;
      case '/quiz-result':
        page = const QuizResultScreen();
        break;

      default:
        page = null;
    }
    if (page == null) return null;
    return PageRouteBuilder(
      settings: s,
      pageBuilder: (context, animation, secondaryAnimation) => page!,
      transitionsBuilder: (context, anim, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

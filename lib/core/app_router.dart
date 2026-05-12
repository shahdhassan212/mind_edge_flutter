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
import '../screens/main_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/ocr_processing_screen.dart';
import '../screens/study_plan_screen.dart';
import '../screens/audio_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/library_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/ai_analysis_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/plans_screen.dart';
import '../features/analysis/model/quiz_models.dart';

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
        final args = s.arguments as Map<String, dynamic>? ?? {};
        page = StudyPlanScreen(
          filename: args['filename'] as String?,
        );
        break;
      case '/scan':
        page = const ScanScreen();
        break;

      case '/plans':
        page = const PlansScreen();
        break;

      // ── Upload screen (entry point for AI analysis)
      case '/upload':
        page = const UploadScreen();
        break;

      // ── AI Analysis (requires a file — always comes from /upload)
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
        if (filePath == null) {
          page = const UploadScreen();
        } else {
          page = AIAnalysisScreen(
            file: File(filePath),
            displayName: fileName ?? filePath.split('/').last,
          );
        }
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
      case '/quiz':
        final args = s.arguments as Map<String, dynamic>? ?? {};
        page = QuizScreen(
          filename: args['filename'] as String? ?? '',
          numQuestions: args['numQuestions'] as int? ?? 10,
        );
        break;
      case '/quiz-result':
        final args = s.arguments as Map<String, dynamic>? ?? {};
        page = QuizResultScreen(
          result: args['result'] as QuizSubmitResponse,
          filename: args['filename'] as String? ?? '',
        );
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
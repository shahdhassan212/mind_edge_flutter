# MindEdge — AI-Powered Study Companion

MindEdge is a cross-platform mobile application built with Flutter that transforms static study materials into personalized, interactive learning experiences. By integrating a cloud-based AI backend, the application automates document analysis, quiz generation, study planning, and audio summarization — reducing the manual effort students typically spend organizing and reviewing their coursework.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Core User Flows](#core-user-flows)
- [API Integration](#api-integration)
- [Authentication](#authentication)
- [State Management](#state-management)
- [Design System](#design-system)
- [Getting Started](#getting-started)

---

## Overview

Students frequently struggle with organizing large volumes of study material, identifying key concepts, and maintaining consistent study schedules. MindEdge addresses these challenges by providing an end-to-end AI-assisted study workflow accessible from a single mobile interface.

The application communicates with a RESTful ASP.NET Core backend that handles document processing, natural language understanding, and plan generation. The Flutter client is responsible for all presentation logic, state management, and user interactions.

---

## Features

| Feature | Description |
|---|---|
| Document Analysis | Upload PDFs, images, or Word documents. The AI pipeline extracts raw text, identifies graphs, generates a corrected analysis, and classifies rules and definitions. |
| Quiz Generation | Automatically generates multiple-choice and written-answer questions from uploaded documents. Answers are evaluated server-side with per-question explanations. |
| Study Plan Builder | Generates a structured day-by-day study plan based on the document content, desired duration, daily hours, and difficulty level. |
| Audio Summaries | Converts AI-generated document summaries into audio for passive listening. |
| AI Chat | Allows the user to ask contextual questions about their uploaded document in a conversational interface. |
| Task Management | Users can view and toggle the completion status of individual study tasks across all active plans. |
| Document Library | Centralizes all uploaded files for retrieval and re-analysis. |
| Secure Authentication | JWT-based registration and login with automatic token refresh and secure local storage. |

---

## System Architecture

```
Flutter Client (Dart)
        |
        | HTTPS / REST
        |
ASP.NET Core API (midedge.runasp.net)
        |
        |--- AI Processing Pipeline
        |--- Document Storage
        |--- Study Plan Engine
        |--- Quiz Evaluation Engine
```

The Flutter client follows a layered architecture:

```
UI Layer (Screens / Widgets)
        |
Provider Layer (Riverpod StateNotifiers)
        |
Repository Layer (Dio HTTP calls)
        |
Core Layer (DioClient, TokenStorage, ApiEndpoints)
```

---

## Project Structure

```
lib/
├── core/
│   ├── network/
│   │   ├── dio_client.dart               # Shared Dio instance with interceptor chain
│   │   └── dio_interceptors.dart         # Auth, logging, and error interceptors
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── dio_error_handler.dart
│   ├── api_endpoints.dart                # Single source of truth for all API paths
│   └── token_storage.dart                # Secure JWT persistence (flutter_secure_storage)
│
├── features/
│   ├── auth/
│   │   ├── auth_models.dart              # SignInRequest, SignUpRequest, UserModel, etc.
│   │   ├── auth_repostiries.dart         # Network calls for all auth endpoints
│   │   ├── auth_view_model.dart          # AuthViewModel + infrastructure providers
│   │   └── auth_providers.dart           # Form-level view models (sign in, sign up, OTP)
│   │
│   ├── analysis/
│   │   ├── model/
│   │   │   ├── analysis_models.dart      # VisualAnalysisModel, AudioSummaryModel, RulesModel, etc.
│   │   │   └── quiz_models.dart          # QuizQuestion, QuizGenerateResponse, QuizSubmitResponse
│   │   ├── repository/
│   │   │   ├── analysis_repository.dart  # Document analysis API calls
│   │   │   └── quiz_repository.dart      # Quiz generate and submit API calls
│   │   └── providers/
│   │       ├── analysis_providersl.dart  # AnalysisViewModel + StateNotifierProvider
│   │       └── quiz_providers.dart       # QuizViewModel + StateNotifierProvider
│   │
│   ├── study_plan/
│   │   ├── model/study_plan_models.dart  # StudyPlanResponse, DashboardTask, PlanArchiveItem
│   │   ├── repository/study_plan_repository.dart
│   │   └── providers/study_plan_provider.dart
│   │
│   └── files/
│       ├── models/file_model.dart
│       ├── repositories/files_repository.dart
│       └── providers/files_provider.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_1.dart
│   ├── onboarding_2.dart
│   ├── onboarding_3.dart
│   ├── sign_in.dart
│   ├── sign_up.dart
│   ├── verify_email_screen.dart
│   ├── forgot_password_email.dart
│   ├── forgot_password_code.dart
│   ├── forgot_password_newpass.dart
│   ├── forgot_password_success.dart
│   ├── dashboard_screen.dart
│   ├── upload_screen.dart
│   ├── ai_analysis_screen.dart
│   ├── ai_chat_screen.dart
│   ├── quiz_screen.dart
│   ├── quiz_result_screen.dart
│   ├── study_plan_screen.dart
│   ├── plans_screen.dart
│   ├── audio_screen.dart
│   ├── library_screen.dart
│   ├── scan_screen.dart
│   └── settings_screen.dart
│
├── widgets/
│   ├── common_widgets.dart
│   ├── dashboard_widgets.dart
│   ├── ai_analysis_widgets.dart
│   ├── animation_helpers.dart
│   └── robot_widget.dart
│
├── theme/
│   └── design_tokens.dart               # Color palette, gradients, shadows, typography constants
│
└── app_router.dart                       # Centralized named route definitions and transitions
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod — StateNotifier, FutureProvider, Provider |
| HTTP Client | Dio with custom interceptor chain |
| Authentication | JWT with automatic refresh via AuthInterceptor |
| Secure Storage | flutter_secure_storage |
| File Picking | file_picker |
| Camera | camera package with permission_handler |
| Text Rendering | flutter_markdown |
| Backend | ASP.NET Core Web API |

---

## Core User Flows

**Onboarding and Authentication**
```
Splash -> Onboarding (1/2/3) -> Sign Up -> Email Verification -> Dashboard
                              -> Sign In -> Dashboard
```

**Document Analysis**
```
Dashboard -> Upload Screen -> AI Analysis Screen
                                  -> Summary Tab
                                  -> Rules and Formulas Tab
                                  -> Visual Analysis Tab
                                  -> Definitions Tab
                                  -> AI Chat
```

**Quiz Flow**
```
AI Analysis Screen -> Quiz Screen (MCQ + Written) -> Submit -> Quiz Result Screen
```

**Study Plan Flow**
```
AI Analysis Screen -> Study Plan Screen (form) -> Generate -> Dashboard (tasks visible)
Dashboard -> View Plans -> Plans Screen (archive + task toggle)
```

---

## API Integration

All requests target `https://midedge.runasp.net`. Every feature repository receives the shared `DioClient` instance via Riverpod dependency injection, ensuring the `AuthInterceptor` attaches the Bearer token automatically.

| Module | Method | Endpoint |
|---|---|---|
| Auth | POST | `/api/Auth/register` |
| Auth | POST | `/api/Auth/login` |
| Auth | POST | `/api/Auth/refresh-token` |
| Auth | POST | `/api/Auth/verify-email` |
| Auth | POST | `/api/Auth/forgot-password` |
| Auth | POST | `/api/Auth/reset-password` |
| Document | POST | `/api/Document/analyze-visuals` |
| Document | POST | `/api/Document/summary` |
| Document | GET | `/api/Document/get-rules` |
| Document | GET | `/api/Document/get-definitions` |
| Quiz | POST | `/api/Quiz/generate` |
| Quiz | POST | `/api/Quiz/submit` |
| Study Plan | POST | `/api/StudyPlan/generate` |
| Study Plan | GET | `/api/StudyPlan/dashboard` |
| Study Plan | GET | `/api/StudyPlan/archive-names` |
| Study Plan | GET | `/api/StudyPlan/plan-by-file` |
| Study Plan | PATCH | `/api/StudyPlan/tasks/{id}/toggle` |
| Files | POST | `/api/File/Upload` |
| Files | GET | `/api/File/ListFiles` |

---

## Authentication

The application uses a JWT-based authentication flow:

1. On successful login, the server returns a signed JWT token.
2. The client decodes the token payload client-side to extract user claims (`name`, `email`, `id`) without an additional profile request.
3. The access token and refresh token are persisted using `flutter_secure_storage`.
4. The `AuthInterceptor` automatically attaches the `Authorization: Bearer <token>` header to all non-public requests.
5. On receiving a 401 response, the interceptor attempts a silent token refresh using the stored refresh token. If successful, the original request is retried transparently. If the refresh fails, the session is cleared and the user is redirected to sign in.

---

## State Management

The project uses Riverpod with the `StateNotifier` pattern throughout. Every feature follows the same structure:

```
Repository
    Handles all HTTP communication with the backend.
    Receives DioClient via constructor injection.
    Returns typed model objects or throws on error.

ViewModel (StateNotifier)
    Holds the feature's state (loading, success, failure, data).
    Calls repository methods and updates state accordingly.
    Exposes methods the UI calls directly.

Provider
    Wires the repository and view model together.
    Consumed by ConsumerWidget or ConsumerStatefulWidget in the UI layer.
```

This separation ensures the UI contains no business logic and all state transitions are testable in isolation.

---

## Design System

The visual design is defined entirely in `design_tokens.dart` and follows a warm academic aesthetic:

- **Color Palette:** Parchment cream backgrounds, cocoa browns, and antique gold accents.
- **Typography:** Syne (headings and titles), DM Sans (body and UI text), DM Mono (extracted text and code blocks).
- **Gradients:** Warm cream-to-amber background gradients, gold-cocoa CTA button gradients.
- **Shadows:** Layered soft shadows using `BoxShadow` to create depth without harsh contrast.
- **Motion:** Fade transitions between routes (280ms), animated containers for state changes.

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio or Xcode for device/emulator targets

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/mindedge-flutter.git
cd mindedge-flutter

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## License

This project is submitted as a graduation project. All rights reserved.

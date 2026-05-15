<div align="center">

# MindEdge
### An AI-Powered Education Assistant for Smarter Learning

*Graduation Project — Faculty of Science*

</div>

---

> **MindEdge** is a cross-platform mobile application that transforms any study material — PDFs, slides, scanned notes, or images — into an interactive learning experience powered by Artificial Intelligence. The system delivers automatic summarization, rule and definition extraction, visual graph analysis, conversational Q&A, auto-generated quizzes, and personalized study plans, all from a single uploaded document.

---

## Table of Contents

1. [Abstract](#abstract)
2. [Problem Statement](#problem-statement)
3. [Motivation](#motivation)
4. [Objectives](#objectives)
5. [Scope of the Project](#scope-of-the-project)
6. [Key Features](#key-features)
7. [System Architecture](#system-architecture)
8. [User Flow](#user-flow)
9. [Technology Stack](#technology-stack)
10. [Project Structure](#project-structure)
11. [Methodology](#methodology)
12. [Getting Started](#getting-started)
13. [Configuration](#configuration)
14. [API Reference](#api-reference)
15. [Authentication Flow](#authentication-flow)
16. [State Management](#state-management)
17. [Local Storage](#local-storage)
18. [Building for Release](#building-for-release)
19. [Results & Evaluation](#results--evaluation)
20. [Future Work](#future-work)
21. [Troubleshooting](#troubleshooting)
22. [Team & Supervision](#team--supervision)
23. [Acknowledgements](#acknowledgements)
24. [License](#license)

---

## Abstract

Students today are surrounded by digital learning material, yet they often spend more time organizing and re-reading documents than actually understanding them. **MindEdge** addresses this gap by combining a modern Flutter mobile client with an AI-driven backend to convert raw study material into structured, interactive learning artifacts. The result is a single application where a student can upload a document and immediately obtain a summary, the key rules and definitions, an AI tutor to ask follow-up questions, an auto-generated quiz, and a personalized study plan — replacing a workflow that normally requires several disconnected tools.

---

## Problem Statement

Traditional self-study has three persistent weaknesses:

1. **Information overload.** A typical course produces hundreds of pages of slides, textbooks, and handouts; students struggle to identify what is essential.
2. **Passive reading.** Reading alone is one of the least effective learning techniques; active recall and self-testing improve retention but are time-consuming to prepare manually.
3. **Fragmented tooling.** Students juggle separate apps for note-taking, summarization, flashcards, chatbots, and planning, with no shared context between them.

**MindEdge** unifies these tasks into one mobile application bound to the student's own material.

---

## Motivation

- **Personalized learning** is the single highest-leverage improvement educational technology can offer.
- Recent advances in **Large Language Models** make it feasible to summarize, question-answer, and assess directly from arbitrary student documents.
- Mobile-first delivery makes the tool accessible **anywhere, anytime**, which matches how students actually study.
- As a graduation project, the application demonstrates an end-to-end production-grade pipeline: secure authentication, file ingestion, AI processing, real-time chat, structured assessment, and offline-capable storage.

---

## Objectives

| # | Objective |
| --- | --- |
| 1 | Provide a single mobile entry point for uploading and analyzing academic material. |
| 2 | Automate the extraction of summaries, rules, and definitions from PDFs and images. |
| 3 | Enable conversational interaction with study material via an AI chat bound to each document. |
| 4 | Generate quizzes from uploaded documents and grade them automatically. |
| 5 | Produce personalized study plans with progress tracking on the dashboard. |
| 6 | Deliver a secure, polished, production-quality user experience on Android and iOS. |

---

## Scope of the Project

**In scope**

- Cross-platform Flutter mobile client (Android, iOS).
- ASP.NET backend integration over secure HTTPS.
- Email-based authentication with OTP verification and password recovery.
- Document upload, camera scan, and AI-driven analysis.
- AI chat, quiz generation/grading, and study plan management.
- Local caching of folders for offline browsing.

**Out of scope (current release)**

- Web/desktop clients.
- Collaborative or multi-user study rooms.
- Native offline AI inference (the AI runs server-side).
- Integration with external LMS platforms (Moodle, Google Classroom).

---

## Key Features

| Feature | Description |
| --- | --- |
| **Authentication** | Sign up, sign in, email OTP verification, forgot/reset password, token refresh, secure logout. |
| **Document Upload** | Pick PDFs or images from device storage with `file_picker`. |
| **Camera Scan + OCR** | Capture documents directly via the camera; OCR runs server-side. |
| **AI Analysis** | Summary, rules extraction, definitions, and visual/graph analysis per document. |
| **AI Chat** | Conversational session anchored to the uploaded document with Markdown and LaTeX math rendering. |
| **Quizzes** | Generate quizzes per document, auto-grade, and review detailed results. |
| **Study Plans** | Personalized plan generation, dashboard tasks, and progress tracking. |
| **Library** | Locally cached folders (Hive) that organize uploaded files for fast offline browsing. |
| **Audio Mode** | Audio playback for narrated content. |
| **Onboarding** | Three animated onboarding screens powered by Rive. |
| **Theming** | Centralized design tokens, custom Material theme, and Google Fonts typography. |

---

## System Architecture

MindEdge follows a **feature-first, layered architecture** on the client side, communicating with a remote ASP.NET backend over REST.

```
┌──────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│              Screens · Widgets · Animations                  │
└────────────────────────────┬─────────────────────────────────┘
                             │ consumes
┌────────────────────────────▼─────────────────────────────────┐
│                  State Management Layer                      │
│              Riverpod Providers · ViewModels                 │
└────────────────────────────┬─────────────────────────────────┘
                             │ delegates to
┌────────────────────────────▼─────────────────────────────────┐
│                     Repository Layer                         │
│        Auth · Files · Analysis · Quiz · Study Plan           │
└────────────────────────────┬─────────────────────────────────┘
                             │ calls
┌────────────────────────────▼─────────────────────────────────┐
│                     Network Layer                            │
│        Dio Client · Auth Interceptor · Error Handler         │
└────────────────────────────┬─────────────────────────────────┘
                             │ HTTPS
┌────────────────────────────▼─────────────────────────────────┐
│            Backend — ASP.NET (midedge.runasp.net)            │
│        AI Services · OCR · Database · Token Service          │
└──────────────────────────────────────────────────────────────┘
```

Each feature owns its own `models/`, `repositories/`, and `providers/`. UI screens stay thin and react to provider state via `AsyncValue<T>`.

---

## User Flow

```
Splash
  ├── Token found → Dashboard
  └── No token   → Onboarding (3 screens) → Sign In / Sign Up
                                              │
                                              ▼
                                       Verify Email (OTP)
                                              │
                                              ▼
                                          Dashboard
                                              │
   ┌──────────────┬──────────────┬──────────────┬──────────────┐
   │   Library    │    Upload    │    Plans     │   Settings   │
   └──────────────┴──────┬───────┴──────────────┴──────────────┘
                         │
                    Scan / Pick
                         │
                         ▼
                    AI Analysis
                    │        │
                    ▼        ▼
                 AI Chat    Quiz → Quiz Result
                              │
                              ▼
                         Study Plan

   Forgot Password → OTP Code → New Password → Success → Sign In
```

---

## Technology Stack

**Framework & Language**
- Flutter (SDK `>=3.3.0 <4.0.0`)
- Dart

**State Management**
- `flutter_riverpod` ^2.5.1

**Networking**
- `dio` ^5.4.0 — typed HTTP client with auth and error interceptors.
- `connectivity_plus` ^6.0.3

**Storage**
- `flutter_secure_storage` ^9.0.0 — JWT and refresh tokens (Keychain / EncryptedSharedPreferences).
- `hive` + `hive_flutter` — offline-first local cache for the user's library.

**Media & Files**
- `file_picker`, `image_picker`, `camera`, `permission_handler`, `path_provider`, `open_filex`.

**Audio**
- `just_audio` ^0.9.36, `audio_session` ^0.1.18.

**UI & Animation**
- `google_fonts` ^6.2.1
- `rive` ^0.13.0 — onboarding and mascot animations.
- `flutter_markdown` ^0.7.4 + `flutter_math_fork` ^0.7.4 — render AI responses with Markdown and LaTeX.

**Tooling**
- `flutter_lints`, `flutter_launcher_icons`.

**Backend**
- ASP.NET Core REST API hosted at `https://midedge.runasp.net`.

---

## Project Structure

```
mind_edge/
├── android/                          ← Native Android project
├── ios/                              ← Native iOS project
├── assets/
│   ├── icon/                         ← App icons
│   └── rive/                         ← Rive animation files
├── lib/
│   ├── main.dart                     ← Entry point, Hive init, runApp
│   │
│   ├── core/
│   │   ├── api_endpoints.dart        ← All backend URLs + storage keys
│   │   ├── app_router.dart           ← Centralized named routes
│   │   ├── token_storage.dart        ← Secure JWT storage wrapper
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── dio_error_handler.dart
│   │   └── network/
│   │       ├── dio_client.dart
│   │       └── dio_interceptors.dart
│   │
│   ├── features/
│   │   ├── auth/                     ← Models, repository, view model, providers
│   │   ├── files/                    ← Upload / download / list
│   │   ├── library/                  ← Hive-backed folder library
│   │   └── analysis/
│   │       ├── model/                ← Analysis, chat, quiz, study-plan models
│   │       ├── repository/           ← One repository per AI feature
│   │       └── providers/            ← Riverpod state notifiers
│   │
│   ├── screens/                      ← Auth, dashboard, library, upload,
│   │                                   scan, AI analysis, AI chat, quiz,
│   │                                   study plan, audio, settings, …
│   │
│   ├── widgets/                      ← Reusable UI and animation helpers
│   │
│   └── theme/
│       ├── design_tokens.dart        ← Colors, spacing, typography
│       └── theme.dart                ← MaterialApp ThemeData
│
├── pubspec.yaml
└── README.md
```

---

## Methodology

The project was developed iteratively using an **Agile / Scrum-inspired workflow**:

1. **Requirements gathering** — interviews with students and lecturers to identify pain points in self-study.
2. **System design** — high-level architecture, data models, and UI mockups.
3. **Sprint-based implementation** — feature-first development with each sprint delivering a vertical slice (UI → provider → repository → backend integration).
4. **Continuous testing** — manual testing on Android and iOS devices, supplemented by static analysis (`flutter_lints`).
5. **Iteration on feedback** — refining UX, performance, and error handling after each demo.

Version control was handled via Git with feature branches and conventional commit messages.

---

## Getting Started

### Prerequisites

| Tool | Version |
| --- | --- |
| Flutter SDK | 3.3 or newer |
| Dart | bundled with Flutter |
| Android Studio / Xcode | for emulators and device builds |
| VS Code (recommended) | with Dart and Flutter extensions |

Verify your installation:

```bash
flutter doctor
```

### 1. Clone the repository

```bash
git clone <repository-url>
cd mind_edge
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter devices            # list available devices
flutter run                # run on the default device
flutter run -d <device-id> # run on a specific device
```

In VS Code, press **F5** to start a debug session.

---

## Configuration

### Backend Base URL

All backend URLs live in a single file. Open [lib/core/api_endpoints.dart](lib/core/api_endpoints.dart) and update:

```dart
const String kBaseUrl = 'https://midedge.runasp.net';
```

Endpoints are grouped per feature (`AuthEndpoints`, `FileEndpoints`, `DocumentEndpoints`, `QuizEndpoints`, `StudyPlanEndpoints`). Changing a path only requires editing a constant.

### Android Permissions

In `android/app/src/main/AndroidManifest.xml` (above `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### iOS Permissions

Add the following keys to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>MindEdge uses the camera to scan study materials.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>MindEdge needs photo access to import documents.</string>
<key>NSMicrophoneUsageDescription</key>
<string>MindEdge uses the microphone for audio features.</string>
```

### App Icon

Launcher icons are generated from `assets/icon/Icon_app.png`:

```bash
flutter pub run flutter_launcher_icons
```

---

## API Reference

A summary of the endpoints consumed by the client (full list in [lib/core/api_endpoints.dart](lib/core/api_endpoints.dart)):

**Auth** — `/api/Auth/`
- `register`, `login`, `logout`, `me`
- `verify-email`, `resend-otp`
- `forgot-password`, `reset-password`, `change-password`
- `refresh-token`

**Files** — `/api/File/`
- `Upload`, `Download`, `ListFiles`

**Document Analysis** — `/Document/` and `/documents/`
- `analyze`, `summary`, `get-rules`, `get-definitions`
- `documents/upload`, `documents/{id}`

**Quizzes** — `/quizzes/`
- `generate`, `{id}/submit`, `{id}/results`

**Study Plans** — `/study-plans/`
- `create`, `getAll`, `{id}`

Interactive API documentation (Swagger): `https://midedge.runasp.net/swagger/index.html`

---

## Authentication Flow

1. On launch, **SplashScreen** asks `TokenStorage` for a stored access token.
2. If a valid token exists, the user is routed to **Dashboard**.
3. Otherwise, the flow proceeds through **Onboarding** → **Sign In / Sign Up**.
4. Sign Up triggers an OTP email; the user verifies via **VerifyEmailScreen**.
5. The Dio auth interceptor attaches `Authorization: Bearer <token>` to every request.
6. On a `401` response, the refresh interceptor calls `/api/Auth/refresh-token` and transparently retries the original request.
7. The **Forgot Password** flow: email → OTP code → new password → success → sign in.

Tokens are persisted using `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android).

---

## State Management

The app uses **Riverpod** providers exclusively:

- `authProvider` / `currentUserProvider` — session and profile.
- `filesProvider` — uploaded files cache.
- `libraryFolderProvider` — Hive-backed folder tree.
- `analysisProvider`, `chatProvider`, `quizProvider`, `studyPlanProvider` — feature notifiers wrapping their repositories.

All async state is exposed as `AsyncValue<T>` so the UI can render loading, data, and error cases cleanly with `.when(...)`.

---

## Local Storage

| Purpose | Mechanism |
| --- | --- |
| Access and refresh tokens, user blob | `flutter_secure_storage` |
| Library folders (offline-first) | `Hive` box `kFoldersBoxName` (opened in `main.dart`) |
| Downloaded files / cached documents | `path_provider` application documents directory |

---

## Building for Release

### Android (APK)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Then archive and upload through Xcode.

> Remember to bump the version in `pubspec.yaml` (`version: 1.0.0+1` → `1.0.1+2` …) before each release build.

---

## Results & Evaluation

The delivered prototype achieves the project objectives:

- **End-to-end working pipeline** from authentication to AI-generated study artifacts.
- **Stable performance** on mid-range Android devices, with sub-second navigation transitions.
- **Resilient networking** — automatic token refresh, structured error handling, and connectivity awareness.
- **Polished user experience** — Rive animations, custom theming, Markdown + LaTeX rendering for math-heavy content.
- **Offline-first library** — uploaded folders remain browsable without an internet connection thanks to Hive.

The application was demonstrated to faculty supervisors and tested with sample academic documents (lecture slides, textbook chapters, and handwritten notes), producing coherent summaries, accurate rule extraction, and contextually relevant quiz questions.

---

## Future Work

- **Collaborative study rooms** — shared chats and quizzes between students.
- **Native offline AI** — on-device inference for summarization in low-connectivity scenarios.
- **LMS integration** — direct import from Moodle, Google Classroom, and Microsoft Teams.
- **Spaced-repetition flashcards** generated from extracted definitions.
- **Multi-language support** — Arabic-first UI with bidirectional layout.
- **Web and desktop clients** built from the same Flutter codebase.
- **Analytics dashboard** for tracking long-term learning progress.

---

## Troubleshooting

**`flutter pub get` fails or dependencies clash**
```bash
flutter clean
flutter pub get
```

**App cannot reach the backend on Android**
- Confirm `INTERNET` permission in `AndroidManifest.xml`.
- If targeting a local HTTP backend, add a `network_security_config.xml` and reference it via `android:networkSecurityConfig`.

**Camera or storage permissions denied**
- Re-check `Info.plist` (iOS) and `AndroidManifest.xml` (Android).
- Reset permissions in OS settings and reinstall the app.

**Hive box errors after model changes**
- Uninstall the app or clear its data to drop incompatible Hive boxes.

**OTP / email never arrives**
- Verify the account email and check the spam folder.
- Use `resend-otp` from the Verify Email screen.

---

## Team & Supervision

**Project Team**
- *Member 1 — Role*
- *Member 2 — Role*
- *Member 3 — Role*
- *Member 4 — Role*

**Supervised by**
- *Dr. [Supervisor Name]* — Faculty of Computers and Artificial Intelligence

> Please replace the placeholders above with the final team and supervisor names before the discussion.

---

## Acknowledgements

- The Flutter and Dart teams for an outstanding cross-platform framework.
- The open-source communities behind **Riverpod**, **Dio**, **Hive**, and **Rive**.
- Our supervisors and the Faculty of Computers and Artificial Intelligence for their guidance throughout the project.
- Fellow students who participated in user-testing sessions and provided valuable feedback.

---

## License

This project was developed as a **graduation project** for academic and educational purposes. All rights reserved by the project authors and the Faculty of Computers and Artificial Intelligence.

---

<div align="center">

*MindEdge — Turning every document into a personalized learning experience.*

</div>

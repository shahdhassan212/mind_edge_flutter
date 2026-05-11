# MindEdge — AI-Powered Education Assistant

> A cross-platform Flutter application that turns any study material — PDFs, slides, scanned notes, or images — into an interactive learning experience powered by AI: summaries, definitions, rules, visual graph analysis, conversational Q&A, auto-generated quizzes, and personalized study plans.

**Graduation Project • Faculty of Computers and Artificial Intelligence**

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Screens & User Flow](#screens--user-flow)
4. [Tech Stack](#tech-stack)
5. [Architecture](#architecture)
6. [Project Structure](#project-structure)
7. [Getting Started](#getting-started)
8. [Configuration](#configuration)
9. [API Endpoints](#api-endpoints)
10. [Authentication Flow](#authentication-flow)
11. [State Management](#state-management)
12. [Local Storage](#local-storage)
13. [Building for Release](#building-for-release)
14. [Troubleshooting](#troubleshooting)

---

## Overview

**MindEdge** is an intelligent study companion designed to help students absorb academic content faster and more effectively. The app accepts uploaded documents (PDF, DOCX, images) or live camera scans, processes them through an AI backend, and produces:

- Concise **summaries** of the material.
- Extracted **rules**, **definitions**, and **key concepts**.
- **Visual analysis** of charts and figures embedded in documents.
- An **AI chat** session bound to the document for follow-up questions.
- Auto-generated **quizzes** with instant grading and feedback.
- A personalized **study plan** with progress tracking on the dashboard.

The mobile client is built in Flutter and talks to an ASP.NET backend hosted at `https://midedge.runasp.net`.

---

## Key Features

| Feature | Description |
| --- | --- |
| **Authentication** | Sign up, sign in, email OTP verification, forgot/reset password, token refresh, secure logout. |
| **Document Upload** | Pick PDFs or images from device storage with `file_picker`. |
| **Camera Scan + OCR** | Capture documents directly via the camera, then run server-side OCR. |
| **AI Analysis** | Summary, rules extraction, definitions, and visual/graph analysis per document. |
| **AI Chat** | Conversational session anchored to the uploaded document with markdown + LaTeX math rendering. |
| **Quizzes** | Generate quizzes by document, auto-grade, and review results. |
| **Study Plans** | Personalized plan generation, dashboard tasks, and progress tracking. |
| **Library** | Locally cached folders (Hive) that organize uploaded files. |
| **Audio Mode** | Audio playback for narrated content. |
| **Onboarding** | Three animated onboarding screens powered by Rive. |
| **Theming** | Centralized design tokens, custom theme, and Google Fonts. |

---

## Screens & User Flow

```
Splash
  ├── Token found → Dashboard
  └── No token   → Onboarding (3 screens) → Sign In / Sign Up
                                              ↓
                                        Verify Email (OTP)
                                              ↓
                                          Dashboard
                                              ↓
   ┌──────────────┬──────────────┬──────────────┬──────────────┐
   │   Library    │    Upload    │    Plans     │   Settings   │
   └──────────────┴──────────────┴──────────────┴──────────────┘
          │              │               │
          │         Scan / Pick          │
          │              ↓               │
          │       AI Analysis ←──────────┘
          │         ↓        ↓
          │      AI Chat   Quiz → Quiz Result
          │                  ↓
          │            Study Plan
          ↓
     Forgot Password → Code → New Password → Success → Sign In
```

---

## Tech Stack

**Framework & Language**
- Flutter (SDK `>=3.3.0 <4.0.0`)
- Dart

**State Management**
- `flutter_riverpod` ^2.5.1

**Networking**
- `dio` ^5.4.0 — typed HTTP client with interceptors for auth and error handling.
- `connectivity_plus` ^6.0.3

**Storage**
- `flutter_secure_storage` ^9.0.0 — JWT and refresh tokens.
- `hive` + `hive_flutter` — local cache for the user's library/folders.

**Media & Files**
- `file_picker`, `image_picker`, `camera`, `permission_handler`, `path_provider`, `open_filex`.

**Audio**
- `just_audio` ^0.9.36, `audio_session` ^0.1.18.

**UI & Animation**
- `google_fonts` ^6.2.1
- `rive` ^0.13.0 — onboarding & mascot animations.
- `flutter_markdown` ^0.7.4 + `flutter_math_fork` ^0.7.4 — render AI responses with markdown and LaTeX math.

**Tooling**
- `flutter_lints`, `flutter_launcher_icons`.

---

## Architecture

The app follows a **feature-first / layered architecture**:

```
Presentation (screens, widgets)
        │   uses
        ▼
   ViewModels / Providers (Riverpod)
        │   call
        ▼
     Repositories (per feature)
        │   delegate to
        ▼
   Network Layer (Dio client + interceptors)
        │
        ▼
        Backend (ASP.NET — midedge.runasp.net)
```

Each feature owns its own `models/`, `repositories/`, and `providers/`. UI screens stay thin and only react to provider state.

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
│   │   ├── auth/
│   │   │   ├── auth_models.dart
│   │   │   ├── auth_repostiries.dart
│   │   │   ├── auth_view_model.dart
│   │   │   └── auth_providers.dart
│   │   │
│   │   ├── files/
│   │   │   ├── models/file_model.dart
│   │   │   ├── repositories/files_repository.dart
│   │   │   └── providers/files_provider.dart
│   │   │
│   │   ├── library/
│   │   │   ├── models/folder_model.dart
│   │   │   ├── repositories/library_folder_repository.dart
│   │   │   └── providers/library_folder_providers.dart
│   │   │
│   │   └── analysis/
│   │       ├── model/
│   │       │   ├── analysis_models.dart
│   │       │   ├── chat_models.dart
│   │       │   ├── quiz_models.dart
│   │       │   └── study_plan_models.dart
│   │       ├── repository/
│   │       │   ├── analysis_repository.dart
│   │       │   ├── chat_repository.dart
│   │       │   ├── quiz_repository.dart
│   │       │   └── study_plan_repository.dart
│   │       └── providers/
│   │           ├── analysis_providersl.dart
│   │           ├── chat_providers.dart
│   │           ├── quiz_providers.dart
│   │           └── study_plan_provider.dart
│   │
│   ├── screens/                      ← All UI screens (auth, dashboard,
│   │                                   library, upload, scan, OCR,
│   │                                   AI analysis, AI chat, quiz,
│   │                                   study plan, audio, settings, …)
│   │
│   ├── widgets/                      ← Reusable UI components &
│   │                                   animation helpers
│   │
│   └── theme/
│       ├── design_tokens.dart        ← Colors, spacing, typography
│       └── theme.dart                ← MaterialApp ThemeData
│
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

| Tool | Version |
| --- | --- |
| Flutter SDK | 3.3 or newer |
| Dart | bundled with Flutter |
| Android Studio / Xcode | for emulators / device builds |
| VS Code (recommended) | with **Dart** and **Flutter** extensions |

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
# List available devices
flutter devices

# Run on the default device
flutter run

# Or pick a specific device
flutter run -d <device-id>
```

In VS Code you can also press **F5** to start debugging.

---

## Configuration

### Backend Base URL

All backend URLs live in a single file. Open [lib/core/api_endpoints.dart](lib/core/api_endpoints.dart) and update:

```dart
const String kBaseUrl = 'https://midedge.runasp.net';
```

Endpoints are grouped per feature (`AuthEndpoints`, `FileEndpoints`, `DocumentEndpoints`, `QuizEndpoints`, `StudyPlanEndpoints`). To change a path, edit the constant — no other code change is required.

### Android Permissions

`android/app/src/main/AndroidManifest.xml` must declare (above `<application>`):

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

Launcher icons are generated from `assets/icon/Icon_app.png` via:

```bash
flutter pub run flutter_launcher_icons
```

---

## API Endpoints

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

Interactive API docs (Swagger): `https://midedge.runasp.net/swagger/index.html`

---

## Authentication Flow

1. On launch, **SplashScreen** asks `TokenStorage` for a stored access token.
2. If a valid token exists → navigate to **Dashboard**.
3. Otherwise → **Onboarding** → **Sign In** / **Sign Up**.
4. Sign Up triggers an OTP email; the user verifies via **VerifyEmailScreen**.
5. The Dio auth interceptor attaches `Authorization: Bearer <token>` to every request.
6. On `401`, the refresh interceptor calls `/api/Auth/refresh-token` and retries the original request transparently.
7. `Forgot Password` flow: email → OTP code → new password → success → sign in.

Tokens are persisted using `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android).

---

## State Management

The app uses **Riverpod** providers exclusively:

- `authProvider` / `currentUserProvider` — session and profile.
- `filesProvider` — uploaded files cache.
- `libraryFolderProvider` — Hive-backed folder tree.
- `analysisProvider`, `chatProvider`, `quizProvider`, `studyPlanProvider` — feature notifiers that wrap their respective repositories.

All async state is exposed as `AsyncValue<T>` so the UI can render loading / data / error cleanly with `.when(...)`.

---

## Local Storage

| Purpose | Mechanism |
| --- | --- |
| Access & refresh tokens, user blob | `flutter_secure_storage` |
| Library folders (offline-first) | `Hive` box `kFoldersBoxName` (opened in `main.dart`) |
| Downloaded files / cached docs | `path_provider` app documents directory |

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

Then archive and upload via Xcode.

> Remember to bump the version in `pubspec.yaml` (`version: 1.0.0+1` → `1.0.1+2` …) before each release build.

---

## Troubleshooting

**`flutter pub get` fails or dependencies clash**
```bash
flutter clean
flutter pub get
```

**App can't reach the backend on Android**
- Confirm `INTERNET` permission in `AndroidManifest.xml`.
- If you target a local backend (HTTP), add a `network_security_config.xml` and reference it via `android:networkSecurityConfig`.

**Camera or storage permissions denied**
- Re-check `Info.plist` (iOS) and `AndroidManifest.xml` (Android).
- Reset permissions in the OS settings and reinstall the app.

**Hive box errors after model changes**
- Delete the app's data or uninstall/reinstall to drop incompatible Hive boxes.

**OTP / email never arrives**
- Verify the account email is correct and check spam.
- Use `resend-otp` from the Verify Email screen.

---

## License

This project was developed as a **graduation project** for educational purposes. All rights reserved by the project authors.

---

## Acknowledgements

- The Flutter and Dart teams.
- The Riverpod, Dio, Hive, and Rive open-source communities.
- Our supervisors and the Faculty of Computers and Artificial Intelligence.

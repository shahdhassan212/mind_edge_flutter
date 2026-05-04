# MindEdge — Flutter App

## Opening in VS Code (Step by Step)

### Prerequisites
Make sure you have these installed:
1. **Flutter SDK** — https://docs.flutter.dev/get-started/install
2. **VS Code** — https://code.visualstudio.com/
3. **Dart + Flutter extensions** — Install from VS Code Extensions marketplace

### Step 1 — Open the project
```
File → Open Folder → select the `mindedge_full` folder
```
Or from terminal:
```bash
code /path/to/mindedge_full
```

### Step 2 — Get dependencies
Open the VS Code terminal (`` Ctrl+` ``) and run:
```bash
flutter pub get
```

### Step 3 — Android setup (for physical device or emulator)
Add internet permission to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
This line goes ABOVE the `<application>` tag.

For flutter_secure_storage, also add inside `<application>`:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

### Step 4 — Run the app
- Press **F5** (or Run → Start Debugging)
- Select "MindEdge (Debug)" from the launch config
- Choose your device/emulator from the status bar at the bottom

### Step 5 — Connect to the backend
Open `lib/core/constants/api_endpoints.dart` and verify the base URL:
```dart
const String kBaseUrl = 'https://midedge.runasp.net';
```
Compare each endpoint path with your Swagger UI and update if needed.

## Project Structure
```
lib/
├── main.dart                    ← App entry point + routes
├── core/
│   ├── constants/api_endpoints.dart  ← ALL URLs here
│   ├── errors/                       ← Error types + handler
│   ├── network/                      ← Dio client + interceptors
│   └── storage/token_storage.dart    ← JWT storage
├── features/auth/
│   ├── models/auth_models.dart       ← Request/response models
│   ├── services/auth_service.dart    ← Raw API calls
│   ├── state/auth_state.dart         ← Immutable states
│   └── providers/auth_providers.dart ← Riverpod notifiers
├── screens/                     ← All UI screens
├── widgets/                     ← Shared UI components
├── animations/animation_helpers.dart
└── theme/                       ← Colors, tokens, theme
```

## API Endpoints
All endpoints are in `lib/core/constants/api_endpoints.dart`.
Open Swagger at https://midedge.runasp.net/swagger/index.html
and verify/update the paths if any differ.

## Updating an Endpoint (When Backend Changes)
1. Open `lib/core/constants/api_endpoints.dart`
2. Change the string value of the affected endpoint
3. Nothing else in the codebase needs to change

## Auth Flow
```
Splash → checks stored token
  ├── Has token → Dashboard
  └── No token → Onboarding → Sign In / Sign Up
                                    ↓
                              Forgot Password
                              → OTP Verify
                              → New Password
                              → Success → Sign In
```

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**TikTok Clone** - A full-featured social video sharing application built with Flutter, implementing core TikTok functionalities.

### Tech Stack
- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **State Management**: TBD (Provider/Riverpod/Bloc)
- **Testing**: Unit Testing, Widget Testing, Integration Testing

### Planned Features
- 📹 Video recording and upload
- 👤 User profiles and authentication
- ❤️ Like system
- 💬 Comments
- 📨 Direct messaging (DM)
- 🎬 Video feed with infinite scroll
- 🔍 Search and discovery
- 📱 Responsive design
- ✨ Animations and transitions

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app on connected device/emulator
flutter run

# Run with specific platform
flutter run -d chrome    # Web
flutter run -d ios       # iOS Simulator
flutter run -d android   # Android Emulator

# Build commands
flutter build apk        # Android APK
flutter build ios        # iOS (requires macOS)
flutter build web        # Web build

# Code quality
flutter analyze          # Static code analysis
flutter format .         # Format all Dart files

# Testing
flutter test             # Run all tests
flutter test test/unit   # Run unit tests
flutter test test/widget # Run widget tests
flutter test integration_test # Run integration tests
```

### Firebase Setup (Future)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase in project
flutterfire configure

# Deploy Firebase functions
firebase deploy --only functions
```

## Architecture & Code Structure

### Design Pattern: Feature-First Architecture
The codebase follows a feature-first organization pattern where screens are grouped by feature rather than by technical layer.

```
lib/
├── constants/         # Application-wide constants
│   ├── gaps.dart     # SizedBox constants for consistent spacing
│   └── sizes.dart    # Size constants for UI consistency
├── screens/features/  # Feature modules
│   ├── authentication/
│   │   ├── widgets/  # Reusable auth widgets
│   │   ├── birthday_screen.dart
│   │   ├── email_screen.dart
│   │   ├── login_form_screen.dart
│   │   ├── login_screen.dart
│   │   ├── password_screen.dart
│   │   ├── sign_up_screen.dart
│   │   └── username_screen.dart
│   ├── onboarding/   
│   ├── videos/       # (Future) Video feed, recording
│   ├── discover/     # (Future) Search and discovery
│   ├── inbox/        # (Future) DMs and notifications
│   └── profile/      # (Future) User profiles
└── main.dart         # App entry point and theme configuration
```

## Development Guidelines

### 1. UI/UX Consistency
- **Spacing**: Always use `Gaps` constants (e.g., `Gaps.v20`, `Gaps.h16`)
- **Sizes**: Use `Sizes` constants for all dimensions
- **Colors**: Define in theme, avoid hardcoded colors
- **Theme**: Maintain consistent theming through `ThemeData`

### 2. State Management Guidelines
- Use `StatefulWidget` for screens with form inputs
- Dispose controllers properly in `dispose()` method
- Real-time validation with `addListener()` pattern
- Maintain single source of truth for app state

### 3. Navigation Patterns
```dart
// Standard navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextScreen()),
);

// With data passing (future)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NextScreen(data: myData),
  ),
);
```

### 4. Form Handling Best Practices
- Always dispose `TextEditingController`
- Implement real-time validation
- Use `GestureDetector` for custom buttons
- Dismiss keyboard on tap outside: `FocusScope.of(context).unfocus()`

### 5. Firebase Integration (Future)
- Separate Firebase logic into service classes
- Handle errors gracefully with user-friendly messages
- Implement proper loading states
- Cache data when appropriate

### 6. Testing Requirements
- Write unit tests for business logic
- Widget tests for critical UI components
- Integration tests for user flows
- Maintain >80% code coverage

### 7. Performance Optimization
- Lazy load heavy components
- Implement proper image caching
- Use `const` constructors where possible
- Optimize video loading and playback

### 8. Responsive Design Principles
- Test on multiple screen sizes
- Use `MediaQuery` for responsive layouts
- Implement adaptive UI for tablets
- Ensure web app is responsive

### 9. Animation Guidelines
- Keep animations smooth (60fps)
- Use Flutter's built-in animation widgets
- Follow Material Design motion principles
- Test on lower-end devices

## Common Patterns & Solutions

### Authentication Flow Pattern
1. `SignUpScreen` → Entry point
2. `UsernameScreen` → Username selection
3. `EmailScreen` → Email input with validation
4. `PasswordScreen` → Password with requirements
5. `BirthdayScreen` → Age verification (12+ years)
6. `InterestsScreen` → Onboarding completion

### Widget Patterns

#### Static Constants Access
```dart
// ✅ Correct
Gaps.v20
Sizes.size16

// ❌ Wrong
Gaps().v20
Sizes().size16
```

#### Form Button Pattern
```dart
GestureDetector(
  onTap: _onSubmit,
  child: FormButton(disabled: _isDisabled),
)
```

#### Focus Dismissal Pattern
```dart
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: Scaffold(...),
)
```

#### Date Handling
```dart
// 12 years ago from today
DateTime initialDate = DateTime(
  DateTime.now().year - 12,
  DateTime.now().month,
  DateTime.now().day,
);
```

## Dependencies
- `flutter`: SDK ^3.9.0
- `font_awesome_flutter: ^10.3.0` - Icons
- `cupertino_icons: ^1.0.8` - iOS-style icons
- **Planned**: 
  - `firebase_core` - Firebase initialization
  - `firebase_auth` - Authentication
  - `cloud_firestore` - Database
  - `firebase_storage` - Media storage
  - `video_player` - Video playback
  - `camera` - Video recording
  - `permission_handler` - Permissions
  - `image_picker` - Media selection

## Git Workflow
- Branch naming: `feature/feature-name`, `fix/bug-name`
- Commit messages: Use conventional commits
- PR reviews required before merge
- Keep commits atomic and descriptive

## Common Issues & Solutions

1. **Static member access error**: Use `Gaps.v20` not `Gaps().v20`
2. **Focus not dismissing**: Ensure `GestureDetector.onTap` calls the function
3. **Button not working**: Wrap `FormButton` with `GestureDetector`
4. **Navigation issues**: Check context availability
5. **Form validation**: Use `TextEditingController.addListener()`

## Security Considerations
- Never commit API keys or secrets
- Use environment variables for configuration
- Implement proper authentication checks
- Validate all user inputs
- Sanitize data before Firebase operations
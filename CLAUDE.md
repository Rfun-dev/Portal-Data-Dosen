# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (choose a connected device or emulator)
flutter run

# Run on a specific platform
flutter run -d windows
flutter run -d chrome

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint / static analysis
flutter analyze

# Build
flutter build apk          # Android
flutter build windows      # Windows
flutter build web          # Web
```

## Architecture

This is a standard Flutter multi-platform app targeting Android, iOS, Windows, macOS, Linux, and Web.

- `lib/main.dart` — single entry point; contains `MyApp` (root `MaterialApp`) and `MyHomePage` (stateful counter widget)
- `test/widget_test.dart` — widget tests using `flutter_test`
- `analysis_options.yaml` — uses `package:flutter_lints/flutter.yaml` lint ruleset; suppress per-line with `// ignore: rule_name`
- Platform runners live in `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` — these are generated scaffolding and rarely need manual edits

State management uses plain `setState` (no external state library). The project has no custom assets, fonts, or routes yet.

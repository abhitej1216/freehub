# FreeHub – Personal Free Internet Resources Directory

[![Build FreeHub Android APK](https://github.com/abhitej1216/freehub/actions/workflows/build_apk.yml/badge.svg)](https://github.com/abhitej1216/freehub/actions/workflows/build_apk.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.27.4-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**FreeHub** is a production-quality, offline-first personal directory application for Android, Web, and Desktop inspired by [FMHY (FreeMediaHeckYeah)](https://fmhy.net/).

It indexes curated free websites, software tools, educational materials, streaming services, and AI resources.

---

## Key Features

- **100% Offline Capability**: Uses local SQLite storage (`sqflite` on mobile/desktop, WebAssembly IndexedDB via `sqflite_common_ffi_web` on web). Never depends on external servers or FMHY being online.
- **449 Curated FMHY Directory Resources**: Pre-scraped and bundled inside the app across 15 standard categories. Automatically loaded on first launch or restorable at any time.
- **Independent Resource Management (CRUD)**: Add, edit, delete, search, categorize, and bookmark internet resources independently. Custom resources (`CUSTOM`) are preserved across imports.
- **JSON Import & Export**: Full backup and restore using Schema v1 with interactive preview dialogs and duplicate URL conflict resolution (skip vs update).
- **Themes**: Material 3 theming supporting Dark, AMOLED Black, Light, and System Default.
- **Global Search**: Search across titles, URLs, descriptions, categories, and tags with license filters (Free, Freemium, Open Source).
- **Visit Tracker**: Tracks frequently visited resources with an option to clear browsing history.

---

## Architecture & Technology Stack

Built using **Clean Architecture** with separation of concerns:

- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) with `StatefulShellRoute`
- **Database**: SQLite via `sqflite` and `sqflite_common_ffi_web`
- **Preferences**: `shared_preferences`
- **File Sharing**: `share_plus` & `file_picker`
- **Styling**: Flutter Material 3

---

## Getting Started

### 1. Prerequisites
- Flutter SDK 3.27+ (Dart 3.6+)
- Chrome (for web testing) or Android SDK (for native Android builds)

### 2. Run Locally in Chrome
```bash
flutter run -d chrome
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Build Android APK
```bash
flutter build apk --debug
```
The APK will be generated at `build/app/outputs/flutter-apk/app-debug.apk`.
*(Or download the prebuilt APK from the [GitHub Actions artifacts](https://github.com/abhitej1216/freehub/actions))*

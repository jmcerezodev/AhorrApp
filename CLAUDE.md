# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## Preferences
- **Language**: Always interact and explain in Spanish.
- **Git**: Never suggest or perform git commits. The user handles all version control manually.

## Commands

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Lint / static analysis
flutter analyze

# Build (Android)
flutter build apk

# Build (iOS)
flutter build ios

# Regenerate Isar schema and other generated code
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs
```

## Architecture

This app follows **Clean Architecture** with three layers:

```
lib/
├── config/          # GoRouter routes, theme
├── core/            # DI (GetIt), utilities, sync, auth
├── data/            # Repository implementations, local DB, remote API
├── domain/          # Entities, abstract repository interfaces, usecases
└── presentation/    # Cubits, screens, widgets
```

### Dependency Injection

`lib/core/di/service_locator.dart` is the single registration point for all services, repositories, usecases, and cubits. `GetIt` is used as the service locator. Repositories are registered with `instanceName` parameters (`'local'`, `'remote'`, `'shopping_local'`, etc.) to distinguish dual implementations.

### State Management

Cubits (BLoC pattern) are used throughout. Two categories:
- **Singleton cubits** — registered in `ServiceLocator`, live for the entire app lifetime (e.g., `TotalMoneyCubit`, `HistoryCubit`, `ThemeCubit`)
- **Factory cubits** — created per-screen (e.g., `IncomesCubit`, `ExpensesCubit`, `NewUserCubit`)

States use `Equatable` and `FormzStatus` for form validation states.

### Data Layer

**Offline-first** with background sync:
- **Local**: Isar NoSQL database (`LocalDbService`), accessed via `Isar*Repository` implementations
- **Remote**: Appwrite BaaS via `Appwrite*Repository` implementations
- **Sync**: `SyncService` detects connectivity changes and syncs pending local writes to Appwrite. Pending changes are queued in Isar (`PendingSyncSchema`) and retried with exponential backoff.

Each entity domain (movements, savings, shopping list, debts/loans, recurrent expenses, tickets) has:
1. An abstract interface (`IMovementRepository`, etc.) in `domain/`
2. A local Isar implementation in `data/local/`
3. A remote Appwrite implementation in `data/appwrite/`
4. Usecases that accept both implementations and coordinate sync

### Navigation

`GoRouter` (`lib/config/routes/app_router.dart`) handles routing. Initial route is determined by auth state from `SharedPreferences`.

### Key Features

- **OCR + Document scanning**: `google_mlkit_text_recognition` + `google_mlkit_document_scanner` parse receipt images
- **OpenAI integration**: `lib/data/services/openai_service.dart` extracts structured data from OCR text
- **Biometric auth**: `local_auth` + `SecurityCubit` control app lock
- **PDF export**: `pdf` + `printing` packages for financial reports
- **Charts**: `fl_chart` for financial visualizations

### Code Generation

Isar collection schemas use `@collection` annotations and generate `*.g.dart` files via `build_runner`. Never edit generated files manually.

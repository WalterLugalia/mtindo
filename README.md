# Mtindo

A Flutter application for browsing live fashion products and voting on community favorites.

## Environment Configuration

### Problem
API keys and backend credentials (RapidAPI key, Supabase URL/anon key) cannot be hardcoded into source files, since this project is version-controlled on GitHub. Hardcoding secrets would expose them publicly and make key rotation difficult.

### Solution Implemented

#### Environment-Driven Configuration
- **Location**: `lib/core/config/env_config.dart`
- **Functionality**:
  - Reads all secrets via `--dart-define` flags at build/run time, never stored in source
  - Validates all required keys are present at app startup, failing fast with a clear error if any are missing, rather than failing later inside a network call

#### Centralized Constants
- **Location**: `lib/core/constants/`
- **Functionality**:
  - `api_constants.dart` — API base URL, headers, timeouts, pagination size
  - `storage_constants.dart` — Hive box names and cache staleness window
  - `route_constants.dart` — named route paths

#### Typed Error Handling
- **Location**: `lib/core/errors/`
- **Functionality**:
  - `exceptions.dart` — technical exceptions thrown by services (`NetworkException`, `ApiException`, `CacheException`, `SupabaseException`, `AuthException`, `UnknownException`)
  - `failure.dart` — maps exceptions into clean, user-facing `Failure` types so the UI never depends on Dio/Hive/Supabase-specific error types directly

#### Network Layer
- **Location**: `lib/core/network/`
- **Functionality**:
  - `network_info.dart` — connectivity check, abstracted behind an interface for testability
  - `api_client.dart` — Dio-based client configured with RapidAPI headers, timeouts, and Dio-error-to-`ApiException` mapping

### Usage

#### For Developers
```bash
flutter run \
  --dart-define=RAPID_API_KEY=your_key \
  --dart-define=RAPID_API_HOST=asos2.p.rapidapi.com \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

Missing any of the four values throws a `StateError` listing exactly which key is missing.

### Testing
To verify environment configuration:
1. Run the app with all four `--dart-define` values set
2. Confirm the console logs `Supabase init completed` with no errors
3. Deliberately omit one `--dart-define` flag and confirm `EnvConfig.validate()` throws a clear error naming the missing key

## Architecture

Feature-first, MVVM-style, using Riverpod for state management. Each feature follows: **Screen (View) → Provider (ViewModel) → Service/Repository (Model/Data) → Model**.

## Tech Stack

Flutter, Riverpod, Supabase (auth + votes), Hive (offline cache), Dio, ASOS API via RapidAPI, go_router

## Getting Started

This project is a Flutter application. See the [Environment Configuration](#environment-configuration) section above for required setup before running.

For general Flutter development help, see the [online documentation](https://docs.flutter.dev/).

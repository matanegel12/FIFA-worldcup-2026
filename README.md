# World Cup 2026 Predictions

A Flutter app for predicting FIFA World Cup 2026 match outcomes. Runs on Android, iOS, and Web from a single codebase.

## Prerequisites

- Flutter SDK (see `pubspec.yaml` for minimum SDK version)
- A Firebase project with Authentication and Firestore enabled
- `flutterfire_cli` installed: `dart pub global activate flutterfire_cli`

> Firebase setup is required before the app will run. See the Firebase section below.

## Firebase Setup

Run this once after cloning to connect the app to your Firebase project:

```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` which is not committed to the repo.

## Running the App

### Web

```bash
flutter run -d chrome
```

### Android

Connect a device or start an emulator, then:

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### All available devices

To see all connected devices and emulators:

```bash
flutter devices
```

Then run on a specific device by ID:

```bash
flutter run -d <device-id>
```

## Running Tests

```bash
flutter test
```

## Admin Panel

The admin panel is hidden and accessible only to the admin account (`matan.egel@remepy.com`). Once signed in with that account, the admin panel option will appear in the navigation.

The admin panel lets you:
- Inject mock results for upcoming games
- Reset specific days, guesses, or users
- Seed fake users for leaderboard testing

## Architecture

This app uses the company MVVM architecture via the `mvvm_remepy` package. See `CLAUDE.md` for a full breakdown of the architecture, folder structure, and development rules.

## Design Decisions

| Topic | Decision |
|---|---|
| Timezones | All times stored in UTC, displayed in user's local timezone |
| Guess locking | Locks at kickoff — cannot be changed after |
| Scope | Group stage only (draws are valid outcomes) |
| Set bonus (+2) | All games on the same calendar day (UTC) correct |
| Leaderboard tiebreaker | Earliest to reach the score wins |
| Auth | Firebase Authentication (email + password) |
| Database | Cloud Firestore |

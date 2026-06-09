# FIFA World Cup 2026 Predictions

A Flutter app where users predict match outcomes for the FIFA World Cup 2026. Built with Flutter + Firebase, runs on Android, iOS, and Web from a single codebase.

## What it does

- **Sign up / Sign in** with email and password (Firebase Authentication)
- **Upcoming Games** — browse all 72 WC2026 fixtures grouped by matchday. Tap to predict: Team A wins, Team B wins, or Draw. Predictions lock at kickoff.
- **Results** — see finished games with final scores and outcomes
- **Predictions** — review all your guesses with correct ✅ / incorrect ❌ indicators
- **Leaderboard** — top 10 users ranked by points. Your rank is pinned at the bottom if you are outside the top 10.
- **Scoring** — +1 point per correct prediction. +2 bonus if you correctly predicted every game on the same calendar day.
- **New results popup** — on login, a dialog shows any finished games you have not seen yet.
- **Admin panel** — hidden screen for the admin account to enter final scores. Scoring and leaderboard update automatically.

---

## Prerequisites

- Flutter SDK (see `pubspec.yaml` for minimum SDK version)
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled
- `flutterfire_cli` installed:

```bash
dart pub global activate flutterfire_cli
```

- The `mvvm_remepy` package must be present at `../frontend-v2/packages/mvvm_remepy` (local path dependency)

---

## Firebase Setup

Run once after cloning to generate `lib/firebase_options.dart`:

```bash
flutterfire configure
```

Then create one Firestore composite index (required for the Results page):

- **Collection:** `games`
- **Fields:** `status` Ascending, `kickoffTime` Ascending
- **Scope:** Collection

> Firebase Console → Firestore Database → Indexes → Add Index

---

## Running the App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# List all available devices
flutter devices
```

---

## Running Tests

```bash
flutter test
```

---

## Admin Panel

The admin panel is visible only when signed in with the admin account (`test@test.com` in development). A floating action button (⚙️) appears in the bottom-right corner of the main screen.

The admin panel shows all games where kickoff has passed but no score has been recorded yet. Enter the final score and tap **Save** — the scoring engine runs automatically, user points update, and the leaderboard refreshes.

---

## Design Decisions

| Topic | Decision |
|---|---|
| Timezones | All times stored in UTC, displayed in user's local timezone |
| Guess locking | Locks at kickoff — cannot be changed after |
| Scope | Group stage only (draws are valid outcomes) |
| Set bonus (+2) | All games on the same calendar day (UTC) predicted correctly |
| Leaderboard tiebreaker | Earliest to reach the score wins |
| Auth | Firebase Authentication (email + password) |
| Database | Cloud Firestore |
| Game data | openfootball/worldcup.json — free, no API key, syncs once per 24 hours |
| Scores | Admin panel only — openfootball data is never used to overwrite scores |

---

## Architecture

This app uses the company MVVM architecture via the `mvvm_remepy` package. See `CLAUDE.md` for a full breakdown of the architecture, folder structure, and development rules.

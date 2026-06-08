# CLAUDE.md — FIFA World Cup 2026 Predictions App

## Source of Truth & Priority Order

Before starting any phase:
1. Read `docs/onboarding_worldcup_1.pdf` (the official requirements).
2. Verify the planned implementation matches the PDF.
3. If anything is unclear, **stop and ask** before continuing.

Priority order when sources conflict:
1. User instructions (this conversation)
2. This CLAUDE.md file
3. `docs/onboarding_worldcup_1.pdf`

If there is a conflict between sources, stop and ask.

---

## Project Overview

**Theme:** FIFA World Cup 2026 (opens June 11, 2026 — Mexico vs South Africa)
**Platforms:** Android, iOS, Web (consistent UX across all three)
**Stack:** Flutter + `mvvm_remepy` internal package (from `../frontend-v2/packages/mvvm_remepy`)
**Goal:** A learning project. Finish the app AND understand every decision made along the way.

---

## How Claude Should Work

This is a **learning project**. Every decision must be explained.

### Rules

- Work step by step. Never generate large amounts of code at once.
- Teach while building. Explain why each file exists.
- Explain architecture decisions before writing code.
- Do not create many unrelated files together.
- Prefer small milestones and small commits.
- Ask questions when requirements are unclear.
- Ask before changing architecture.
- Keep code beginner-friendly and readable.

### Before Every Phase

1. Explain the goal of the phase.
2. Explain what we are building.
3. Explain which files will be created.
4. Explain why those files are needed.
5. Explain how they fit into MVVM.
6. Implement.
7. Create tests immediately.
8. Run tests.
9. Fix failures.
10. Summarize what was learned.

---

## Company MVVM Architecture

The app uses the `mvvm_remepy` package. Do not invent another state management approach.

### Core Rules

- Every page has its own **View** (widget), **ViewModel**, and **Page Model**.
- Views contain **no business logic** — they only render state and forward user actions to the ViewModel.
- ViewModels communicate with repositories/services.
- ViewModels **never** call APIs directly.
- Repositories/services handle all data access and persistence.
- Shared domain models live in `lib/models/` (outside feature folders).
- Shared widgets live in `lib/widgets/shared/` (outside feature folders).
- Business logic must never exist inside Flutter widgets.

### Architecture Diagram

```
User Action
     ↓
Feature Page (View)       ← renders state, no logic
     ↓
Feature ViewModel         ← calls repositories, updates Page Model
     ↓
Feature Page Model        ← holds UI state (isLoading, errorMessage, data)
     ↓
Repository / Service      ← abstracts data sources
     ↓
API Client OR Mock Store  ← real data or injected test data
     ↓
Shared Domain Models      ← plain Dart data classes
```

### Data Flow

```
UI → ViewModel → Repository → Data Source
               ← Repository ← Data Source
ViewModel → Page Model → UI Refresh
```

### What Each Layer Is Responsible For

| Layer | Responsibility |
|---|---|
| Page (View) | Render state, dispatch user events |
| ViewModel | Orchestrate: call repos, update Page Model |
| Page Model | Hold UI state: isLoading, errorMessage, list data |
| Repository | Translate between data source and domain models |
| API Client | HTTP calls, JSON parsing |
| Mock Store | In-memory fake data for testing |
| Domain Models | Plain data classes shared across the app |

---

## Folder Structure

```
lib/

  models/                         # Shared domain models
    game.dart
    team.dart
    user.dart
    guess.dart
    leaderboard_entry.dart
    score_summary.dart

  services/

    api/
      world_cup_api_client.dart   # HTTP calls to openfootball or API-Football

    repositories/
      auth_repository.dart
      games_repository.dart
      guesses_repository.dart
      leaderboard_repository.dart

    scoring/
      scoring_calculator.dart     # +1 per game, +2 set bonus — isolated here

    mock/
      mock_store.dart             # In-memory data for admin/test use

    storage/
      session_store.dart          # Persisted auth session

  pages/

    auth/
      sign_in/
        sign_in_page.dart
        sign_in_model.dart
        sign_in_vm.dart
      sign_up/
        sign_up_page.dart
        sign_up_model.dart
        sign_up_vm.dart

    upcoming_games/
      upcoming_games_page.dart
      upcoming_games_model.dart
      upcoming_games_vm.dart
      widgets/
        upcoming_game_card.dart

    predictions/
      predictions_page.dart
      predictions_model.dart
      predictions_vm.dart
      widgets/
        prediction_game_card.dart
        prediction_selector.dart

    results/
      results_page.dart
      results_model.dart
      results_vm.dart
      widgets/
        result_game_card.dart

    leaderboard/
      leaderboard_page.dart
      leaderboard_model.dart
      leaderboard_vm.dart
      widgets/
        leaderboard_row.dart

    admin/
      admin_panel_page.dart
      admin_panel_model.dart
      admin_panel_vm.dart
      widgets/
        mock_result_form.dart
        reset_button.dart

  widgets/
    shared/
      buttons/
      loading_view.dart
      error_view.dart
      empty_state.dart
      team_flag.dart

test/                             # Mirrors lib/ structure
```

### Why This Structure?

- `models/` — domain models are used everywhere, so they live at the top level, not inside a feature folder.
- `services/` — all data access is isolated here. ViewModels never know whether data comes from a real API or a mock.
- `pages/<feature>/` — each feature is self-contained: its View, ViewModel, Page Model, and private widgets.
- `widgets/shared/` — only truly reusable UI components that are used across multiple features.

---

## Functional Requirements (from PDF)

### Auth
- Email + password sign up and sign in via **Firebase Authentication**.
- Persist the session so a returning user stays logged in.
- Database: **Cloud Firestore** for all app data (users, guesses, scores, leaderboard).

### Games
- **Upcoming games** screen: list next fixtures from a real data source.
- **Results** screen: show finished games with final scores.
- Every game row shows the **flags of both teams**.

### Data Source
- **Primary (recommended):** `openfootball/worldcup.json` — free, no key, public-domain JSON with the full 2026 schedule.
- **Alternative:** API-Football (`api-football.com`, `league=1&season=2026`) — live data, requires free API key.
- Wrap whichever is chosen behind a repository interface so the data source can be swapped (real ↔ mock) without touching ViewModels.
- For flags: map FIFA/ISO country codes to `flagcdn.com` or bundle flag assets.

### Predictions & Scoring
- Users guess: **Team A wins**, **Team B wins**, or **Draw**.
- Guesses **lock at kickoff** and cannot be changed after.
- **+1 point** for each correctly guessed game.
- **+2 bonus points** for getting all games on the same day correct (the "set").
- The set definition lives in one clearly-documented function in `scoring_calculator.dart` so it can be changed without touching anything else.

### Leaderboard
- Show **top 10 users** by total points.
- If the logged-in user is outside the top 10, show their rank and points as a pinned row below the table.
- Tiebreaker: earliest to reach the score (deterministic, never ambiguous).

### New Results Popup (Bonus)
- On login, if there are finished-game results the user hasn't seen yet, show a popup dialog summarising them.
- Track per-user which results have been acknowledged. Never show the same result twice.

### Scoring Automation
- After a game finishes, automatically recompute scores, update leaderboard. No live/in-play updates needed.
- Implement as a background service or a hook triggered by the admin panel — same code path in testing and production.

### Admin Panel
- Hidden panel, visible only to admin email (hardcoded in one `isAdmin` getter).
- Inject mock results for upcoming games (triggers the same scoring path as production).
- Reset controls: reset specific days, clear all guesses, clear/seed users, full reset.
- Seed fake users with guesses for leaderboard testing.

---

## Edge Cases to Decide Before Implementation

These are called out explicitly in the PDF. Decisions must be written into the README.

| Topic | Decision |
|---|---|
| **Timezones** | Store all times in UTC; display in user's local timezone |
| **Guess locking** | Lock at kickoff; admin panel respects this rule too |
| **Draws in knockout stage** | Project is scoped to the group stage only (draws valid) |
| **Set definition for +2 bonus** | All games on the same calendar day (UTC); confirm with buddy |
| **Source of truth when mock and real API disagree** | Data source is explicitly switchable; mock wins during testing |
| **Auth backend** | Firebase Authentication; no plain-text passwords |
| **Leaderboard ties** | Earliest to reach the score wins |

---

## Development Rules

### Never
- Put business logic in pages or widgets.
- Call APIs from ViewModels.
- Skip tests or postpone them until the end.
- Build multiple major features simultaneously.
- Generate large code dumps.

### Always
- Build incrementally.
- Keep responsibilities separated by layer.
- Follow MVVM.
- Explain decisions before writing code.
- Keep code readable and beginner-friendly.
- Commit in small logical steps with clear messages.

---

## Testing Strategy

Testing is **continuous**, not a final phase.

### Rule

Whenever a business function is created:
1. Implement the function.
2. Create tests immediately.
3. Run tests immediately (`flutter test`).
4. Fix all failures before continuing to the next step.

### Required Test Coverage

| Area | What to test |
|---|---|
| **Scoring** | Correct prediction (+1), incorrect prediction, set bonus (+2), edge cases (partial day, empty day) |
| **Repositories** | API JSON mapping, mock store mapping |
| **ViewModels** | Loading state, success state, error state |
| **Predictions** | Guess locking (cannot change after kickoff), prediction update before kickoff |
| **Leaderboard** | Ranking order, tiebreaker (earliest score) |
| **New Results Popup** | Uses `lastVisitedAt` on User + `finishedAt` on Game. Show games where `finishedAt > lastVisitedAt`. Update `lastVisitedAt` on popup dismiss. First-time user (`lastVisitedAt == null`) sees nothing. |
| **Admin Panel** | Reset operations, mock result injection, scoring triggered correctly |

---

## Project Phases

### Phase 1 — Setup
**Goal:** Create project structure, configure MVVM, configure dependencies, create architecture skeleton.

Deliverable: Clean project compiles and runs. Folder structure matches the layout above. `mvvm_remepy` is wired in.

### Phase 2 — Domain Models
**Goal:** Define the shared data classes that every other layer will use.

Build: `Game`, `Team`, `User`, `Guess`, `LeaderboardEntry`, `ScoreSummary`.

Create serialization tests if models have `fromJson`/`toJson`.

### Phase 3 — Data Layer
**Goal:** Build the repository and service layer so ViewModels have something to talk to.

Build: `WorldCupApiClient`, all four repositories, `MockStore`.

Requirements:
- Every repository has a real implementation and a mock implementation.
- Both implement the same interface.
- ViewModels cannot tell the difference.

Create repository tests immediately.

### Phase 4 — Scoring Engine
**Goal:** Implement and fully test the scoring rules before any UI exists.

Build: `scoring_calculator.dart`.

Requirements:
- +1 per correct game.
- +2 set bonus (all games on the same day correct).
- Bonus logic isolated in one function.
- Easy to reconfigure the "set" definition.

**Do not continue to Phase 5 until all scoring tests pass.**

### Phase 5 — Authentication
**Goal:** Sign in, sign up, session persistence.

Build: `SignInPage`, `SignUpPage`, `SessionStore`.

Create ViewModel tests immediately.

### Phase 6 — Upcoming Games
**Goal:** First feature screen: list upcoming fixtures.

Build: `UpcomingGamesPage` with loading, empty, and error states. Team flags shown.

Create ViewModel tests immediately.

### Phase 7 — Predictions
**Goal:** Let users submit and update guesses.

Build: `PredictionsPage` with Team A Win / Team B Win / Draw selection.

Requirements:
- Guesses lock at kickoff.
- Locked guesses are visually distinct from editable ones.
1
Create tests immediately.

### Phase 8 — Results
**Goal:** Show finished games with final scores.

Build: `ResultsPage` with team flags and scores.

Create ViewModel tests immediately.

### Phase 9 — Leaderboard
**Goal:** Rankings screen.

Build: `LeaderboardPage`.

Requirements:
- Top 10 users.
- Current user shown below if outside top 10.
- Deterministic tiebreaker.

Create tests immediately.

### Phase 10 — New Results Popup
**Goal:** Show unseen results on login.

Build: Result acknowledgement system.

Requirements:
- Show only results the user hasn't acknowledged.
- Never show acknowledged results again.

Create tests immediately.

### Phase 11 — Admin Panel
**Goal:** Hidden developer/testing tools.

Build: `AdminPanelPage`.

Requirements:
- Gated by `isAdmin` getter checking hardcoded admin email.
- Inject mock results (triggers same scoring path as production).
- Reset: specific days, all guesses, users, full reset.
- Seed fake users for leaderboard testing.

Create tests immediately.

### Phase 12 — Cross-Platform Polish
**Goal:** App works on all three platforms with great UX.

Requirements:
- Android, iOS, Web all build and run.
- Responsive layouts (phone, tablet, desktop widths).
- Loading / error / empty states on every screen.
- Final README complete.
- Manually run the full flow on all three platforms before marking done.

---

## Definition of Done

The project is complete only when all of the following are true:

- [ ] All requirements in `docs/onboarding_worldcup_1.pdf` are satisfied.
- [ ] Architecture follows company MVVM (`mvvm_remepy` package).
- [ ] All tests pass (`flutter test`).
- [ ] README explains how to run the app and how to open the admin panel.
- [ ] App builds and runs on Android.
- [ ] App builds and runs on iOS.
- [ ] App builds and runs on Web.
- [ ] Admin panel works end-to-end (inject result → scoring updates → leaderboard updates).
- [ ] Scoring logic is correct and covered by unit tests.
- [ ] Leaderboard is correct with deterministic tiebreaker.
- [ ] Full flow has been manually tested before handover.
- [ ] Edge case decisions are documented in the README.

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `mvvm_remepy` | Company MVVM base classes (local path dependency) |
| `flutter` | UI framework |
| `firebase_core` | Required by all Firebase packages |
| `firebase_auth` | Email sign in / sign up |
| `cloud_firestore` | Database — stores users, guesses, scores, leaderboard |
| `flutter_lints` | Lint rules |

The `mvvm_remepy` package lives at `../frontend-v2/packages/mvvm_remepy`.
**Read the package source before using it.** Understanding the base ViewModel's lifecycle and notification mechanism is part of the assignment.

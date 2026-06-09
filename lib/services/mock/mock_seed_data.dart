import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/team.dart';
import '../../models/user.dart';

/// Fake data for development and testing only.

// ── User ──────────────────────────────────────────────────────────────────────

final User kFakeUser = User(
  id: 'test-uid-123',
  email: 'test@test.com',
  displayName: 'Test User',
  totalPoints: 0,
  scoreReachedAt: null,
  lastVisitedAt: DateTime.utc(2026, 6, 6, 0, 0), // June 6 — before all finished games
);

// ── Teams ─────────────────────────────────────────────────────────────────────

const Team kTeamMexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team kTeamSouthAfrica = Team(fifaCode: 'RSA', isoCode: 'za', name: 'South Africa');
const Team kTeamBrazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const Team kTeamArgentina = Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina');
const Team kTeamEngland = Team(fifaCode: 'ENG', isoCode: 'gb-eng', name: 'England');
const Team kTeamFrance = Team(fifaCode: 'FRA', isoCode: 'fr', name: 'France');
const Team kTeamGermany = Team(fifaCode: 'GER', isoCode: 'de', name: 'Germany');
const Team kTeamSpain = Team(fifaCode: 'ESP', isoCode: 'es', name: 'Spain');
const Team kTeamUSA = Team(fifaCode: 'USA', isoCode: 'us', name: 'USA');
const Team kTeamCanada = Team(fifaCode: 'CAN', isoCode: 'ca', name: 'Canada');

// ── Finished games ────────────────────────────────────────────────────────────

final Game kFinishedGame1 = Game(
  id: 'game-1',
  homeTeam: kTeamMexico,
  awayTeam: kTeamSouthAfrica,
  kickoffTime: DateTime.utc(2026, 6, 7, 17, 0),  // June 7 — clearly past
  round: 'Matchday 1',
  ground: 'Mexico City',
  homeScore: 2,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 7, 19, 0),   // June 7 — after kickoff
);

final Game kFinishedGame2 = Game(
  id: 'game-2',
  homeTeam: kTeamBrazil,
  awayTeam: kTeamArgentina,
  kickoffTime: DateTime.utc(2026, 6, 7, 20, 0),  // June 7 — clearly past
  round: 'Matchday 2',
  ground: 'New York',
  homeScore: 1,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 7, 22, 0),   // June 7 — after kickoff
);

final Game kFinishedGame3 = Game(
  id: 'game-3',
  homeTeam: kTeamEngland,
  awayTeam: kTeamFrance,
  kickoffTime: DateTime.utc(2026, 6, 8, 14, 0),  // June 8 — clearly past
  round: 'Matchday 3',
  ground: 'Los Angeles',
  homeScore: 3,
  awayScore: 0,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 8, 16, 0),   // June 8 — after kickoff
);

// ── Games needing results (kickoff passed, no score yet) ─────────────────────
// Use these to test the full admin → scoring → leaderboard → results flow.
//
// Test checklist:
//   1. Admin panel: enter Argentina wins (e.g. 2–1) for game-6 → guess CORRECT
//   2. Admin panel: enter Brazil wins (e.g. 0–1) for game-7  → guess WRONG
//   3. Leaderboard: Test User goes from 0 → 1 pt (only game-6 counts)
//   4. Results: both games appear with the scores you entered
//   5. Predictions: game-6 shows ✅, game-7 shows ❌
//
// game-1 guess is intentionally WRONG (South Africa wins) so it doesn't
// interfere with the 1-pt test.

final Game kGameNeedingResult = Game(
  id: 'game-6',
  homeTeam: kTeamArgentina,
  awayTeam: kTeamFrance,
  kickoffTime: DateTime.utc(2026, 6, 8, 20, 0), // June 8 — past kickoff, no score
  round: 'Matchday 4',
  ground: 'Miami',
  status: GameStatus.upcoming,
);

final Game kGameNeedingResult2 = Game(
  id: 'game-7',
  homeTeam: kTeamGermany,
  awayTeam: kTeamBrazil,
  kickoffTime: DateTime.utc(2026, 6, 8, 23, 0), // June 8 — past kickoff, no score
  round: 'Matchday 5',
  ground: 'Houston',
  status: GameStatus.upcoming,
);

// ── Upcoming games ────────────────────────────────────────────────────────────

final Game kUpcomingGame1 = Game(
  id: 'game-4',
  homeTeam: kTeamGermany,
  awayTeam: kTeamSpain,
  kickoffTime: DateTime.utc(2026, 6, 20, 19, 0),
  round: 'Matchday 8',
  ground: 'Dallas',
  status: GameStatus.upcoming,
);

final Game kUpcomingGame2 = Game(
  id: 'game-5',
  homeTeam: kTeamUSA,
  awayTeam: kTeamCanada,
  kickoffTime: DateTime.utc(2026, 6, 21, 22, 0),
  round: 'Matchday 9',
  ground: 'Toronto',
  status: GameStatus.upcoming,
);

// ── Games list ────────────────────────────────────────────────────────────────

final List<Game> kFakeGames = [
  kFinishedGame1,
  kFinishedGame2,
  kFinishedGame3,
  kGameNeedingResult,
  kGameNeedingResult2,
  kUpcomingGame1,
  kUpcomingGame2,
];

// ── Guesses ───────────────────────────────────────────────────────────────────

final List<Guess> kFakeGuesses = [
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-1',
    prediction: Prediction.teamBWins, // South Africa — wrong (Mexico won 2-1)
  ),
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-2',
    prediction: Prediction.teamAWins, // Brazil — incorrect (was draw)
  ),
  // game-3 intentionally has no guess — tests notGuessed state
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-6',
    prediction: Prediction.teamAWins, // Argentina — enter Argentina wins in admin → ✅ +1 pt
  ),
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-7',
    prediction: Prediction.teamAWins, // Germany — enter Brazil wins in admin → ❌ 0 pts
  ),
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-4',
    prediction: Prediction.draw, // upcoming game — pending
  ),
  // game-5 intentionally has no guess — tests notGuessed on upcoming
];

// ── Leaderboard ───────────────────────────────────────────────────────────────

final List<LeaderboardEntry> kFakeLeaderboard = [
  const LeaderboardEntry(rank: 1, userId: 'user-1', displayName: 'John Smith', totalPoints: 10),
  const LeaderboardEntry(rank: 2, userId: 'user-2', displayName: 'Alice Brown', totalPoints: 8),
  const LeaderboardEntry(rank: 3, userId: 'user-3', displayName: 'Bob Jones', totalPoints: 7),
  const LeaderboardEntry(rank: 4, userId: 'user-4', displayName: 'Sarah Lee', totalPoints: 6),
  const LeaderboardEntry(rank: 5, userId: 'user-5', displayName: 'Mike Chen', totalPoints: 5),
  const LeaderboardEntry(rank: 6, userId: 'user-6', displayName: 'Emma Davis', totalPoints: 4),
  const LeaderboardEntry(rank: 7, userId: 'user-7', displayName: 'James Wilson', totalPoints: 4),
  const LeaderboardEntry(rank: 8, userId: 'user-8', displayName: 'Olivia Taylor', totalPoints: 3),
  const LeaderboardEntry(rank: 9, userId: 'user-9', displayName: 'Liam Martin', totalPoints: 2),
  const LeaderboardEntry(rank: 10, userId: 'user-10', displayName: 'Sophia White', totalPoints: 1),
];

/// Current user's entry when outside the top 10.
final LeaderboardEntry kFakeCurrentUserEntry = LeaderboardEntry(
  rank: 14,
  userId: kFakeUser.id,
  displayName: kFakeUser.displayName,
  totalPoints: 0,
);

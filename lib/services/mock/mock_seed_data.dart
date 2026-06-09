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
  lastVisitedAt: DateTime.utc(2026, 6, 8, 0, 0), // June 8 — before all finished games
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
  kickoffTime: DateTime.utc(2026, 6, 9, 17, 0),
  round: 'Matchday 1',
  ground: 'Mexico City',
  homeScore: 2,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 9, 19, 0), // June 9 — after lastVisitedAt ✅
);

final Game kFinishedGame2 = Game(
  id: 'game-2',
  homeTeam: kTeamBrazil,
  awayTeam: kTeamArgentina,
  kickoffTime: DateTime.utc(2026, 6, 9, 20, 0),
  round: 'Matchday 2',
  ground: 'New York',
  homeScore: 1,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 9, 22, 0), // June 9 — after lastVisitedAt ✅
);

final Game kFinishedGame3 = Game(
  id: 'game-3',
  homeTeam: kTeamEngland,
  awayTeam: kTeamFrance,
  kickoffTime: DateTime.utc(2026, 6, 9, 14, 0),
  round: 'Matchday 3',
  ground: 'Los Angeles',
  homeScore: 3,
  awayScore: 0,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 9, 16, 0), // June 9 — after lastVisitedAt ✅
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
  kUpcomingGame1,
  kUpcomingGame2,
];

// ── Guesses ───────────────────────────────────────────────────────────────────

final List<Guess> kFakeGuesses = [
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-1',
    prediction: Prediction.teamAWins, // Mexico — correct
  ),
  Guess(
    userId: kFakeUser.id,
    gameId: 'game-2',
    prediction: Prediction.teamAWins, // Brazil — incorrect (was draw)
  ),
  // game-3 intentionally has no guess — tests notGuessed state
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

import '../../models/game.dart';
import '../../models/guess.dart';
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
  lastVisitedAt: null,
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
  kickoffTime: DateTime.utc(2026, 6, 11, 19, 0),
  round: 'Matchday 1',
  ground: 'Mexico City',
  homeScore: 2,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 11, 21, 0),
);

final Game kFinishedGame2 = Game(
  id: 'game-2',
  homeTeam: kTeamBrazil,
  awayTeam: kTeamArgentina,
  kickoffTime: DateTime.utc(2026, 6, 12, 16, 0),
  round: 'Matchday 2',
  ground: 'New York',
  homeScore: 1,
  awayScore: 1,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 12, 18, 0),
);

final Game kFinishedGame3 = Game(
  id: 'game-3',
  homeTeam: kTeamEngland,
  awayTeam: kTeamFrance,
  kickoffTime: DateTime.utc(2026, 6, 13, 20, 0),
  round: 'Matchday 3',
  ground: 'Los Angeles',
  homeScore: 3,
  awayScore: 0,
  status: GameStatus.finished,
  finishedAt: DateTime.utc(2026, 6, 13, 22, 0),
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

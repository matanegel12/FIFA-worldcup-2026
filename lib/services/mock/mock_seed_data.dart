import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/team.dart';
import '../../models/user.dart';

/// Fake data for development and testing only.

final User kFakeUser = User(
  id: 'test-uid-123',
  email: 'test@test.com',
  displayName: 'Test User',
  totalPoints: 0,
  scoreReachedAt: null,
  lastVisitedAt: null,
);

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _southAfrica = Team(fifaCode: 'RSA', isoCode: 'za', name: 'South Africa');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const Team _argentina = Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina');

final List<Game> kFakeGames = [
  Game(
    id: '2026-06-11_MEX_RSA',
    homeTeam: _mexico,
    awayTeam: _southAfrica,
    kickoffTime: DateTime.utc(2026, 6, 11, 19, 0),
    status: GameStatus.upcoming,
    round: 'Matchday 1',
    ground: 'Mexico City',
  ),
  Game(
    id: '2026-06-11_BRA_ARG',
    homeTeam: _brazil,
    awayTeam: _argentina,
    kickoffTime: DateTime.utc(2026, 6, 11, 22, 0),
    status: GameStatus.upcoming,
    round: 'Matchday 1',
    ground: 'Los Angeles',
  ),
];

/// Pre-seeded guesses for [kFakeUser] — one per fake game.
final List<Guess> kFakeGuesses = [
  Guess(
    userId: kFakeUser.id,
    gameId: '2026-06-11_MEX_RSA',
    prediction: Prediction.teamAWins,
  ),
  Guess(
    userId: kFakeUser.id,
    gameId: '2026-06-11_BRA_ARG',
    prediction: Prediction.draw,
  ),
];

import '../../models/game.dart';
import '../../models/team.dart';

/// Manually-added games that the openfootball feed does not provide.
///
/// The knockout bracket in the public feed uses placeholder teams ("1A", "W73"),
/// so [WorldCupApiClient] drops those rows. Once a real fixture is known we add
/// it here by hand, and [GameSyncService] writes it to Firestore exactly like an
/// API game: schedule fields only, merged, never overwriting admin-entered scores.
///
/// These are knockout fixtures: they kick off at/after `kKnockoutCutoff`, so the
/// scoring engine automatically scores them at +2 with no match-day set bonus, and
/// the UI shows the "≈120 min" note and the "2 pts" badge — all driven by kickoff
/// time, nothing special to flag here.
///
/// To add a game: copy a block below, set the teams, kickoff (UTC), ground and
/// round, and give it an id in the `YYYY-MM-DD_HOME_AWAY` style used by the API.
const List<Team> _knockoutTeams = [
  Team(fifaCode: 'RSA', isoCode: 'za', name: 'South Africa'),
  Team(fifaCode: 'CAN', isoCode: 'ca', name: 'Canada'),
];

final List<Game> kHardcodedGames = [
  // Round of 32 — South Africa vs Canada
  // Sun 28 Jun 2026, 22:00 Israel time = 19:00 UTC, Los Angeles.
  Game(
    id: '2026-06-28_RSA_CAN',
    homeTeam: _knockoutTeams[0],
    awayTeam: _knockoutTeams[1],
    kickoffTime: DateTime.utc(2026, 6, 28, 19, 0),
    round: 'Round of 32',
    ground: 'Los Angeles',
    status: GameStatus.upcoming,
  ),
];

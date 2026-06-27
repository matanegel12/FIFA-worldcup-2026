import '../../models/game.dart';
import '../../models/team.dart';

/// Manually-added games that the openfootball feed does not provide.
///
/// The knockout bracket in the public feed uses placeholder teams ("1A", "W73"),
/// so [WorldCupApiClient] drops those rows. Once a real fixture is known we add
/// it here by hand, and [GameSyncService] writes it to Firestore exactly like an
/// API game: schedule fields only, merged, never overwriting admin-entered scores.
/// They are seeded on every startup (not gated by the 24h API throttle), so a
/// newly-added fixture shows up on the next launch.
///
/// These are knockout fixtures: they kick off at/after `kKnockoutCutoff`, so the
/// scoring engine automatically scores them at +2 with no match-day set bonus, and
/// the UI shows the "≈120 min" note and the "2 pts" badge — all driven by kickoff
/// time, nothing special to flag here.
///
/// IMPORTANT: kickoffTime is stored in **UTC**. The app displays it in Israel
/// time (UTC+3), so subtract 3 hours from the IL kickoff to get the UTC value.
/// To add a game: copy a block, set the teams, kickoff (UTC), ground and round,
/// and give it an id in the `YYYY-MM-DD_HOME_AWAY` style (date = the UTC date).
final List<Game> kHardcodedGames = [
  // South Africa vs Canada · Sun 28 Jun 2026, 22:00 IL (19:00 UTC) · Los Angeles
  Game(
    id: '2026-06-28_RSA_CAN',
    homeTeam: const Team(fifaCode: 'RSA', isoCode: 'za', name: 'South Africa'),
    awayTeam: const Team(fifaCode: 'CAN', isoCode: 'ca', name: 'Canada'),
    kickoffTime: DateTime.utc(2026, 6, 28, 19, 0),
    round: 'Round of 32',
    ground: 'Los Angeles',
    status: GameStatus.upcoming,
  ),

  // Brazil vs Japan · Mon 29 Jun 2026, 20:00 IL (17:00 UTC) · Houston
  Game(
    id: '2026-06-29_BRA_JPN',
    homeTeam: const Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil'),
    awayTeam: const Team(fifaCode: 'JPN', isoCode: 'jp', name: 'Japan'),
    kickoffTime: DateTime.utc(2026, 6, 29, 17, 0),
    round: 'Round of 32',
    ground: 'Houston',
    status: GameStatus.upcoming,
  ),

  // Germany vs Paraguay · Mon 29 Jun 2026, 23:30 IL (20:30 UTC) · Foxborough
  Game(
    id: '2026-06-29_GER_PAR',
    homeTeam: const Team(fifaCode: 'GER', isoCode: 'de', name: 'Germany'),
    awayTeam: const Team(fifaCode: 'PAR', isoCode: 'py', name: 'Paraguay'),
    kickoffTime: DateTime.utc(2026, 6, 29, 20, 30),
    round: 'Round of 32',
    ground: 'Foxborough',
    status: GameStatus.upcoming,
  ),

  // Netherlands vs Morocco · Tue 30 Jun 2026, 04:00 IL (01:00 UTC) · Monterrey (Guadalupe)
  Game(
    id: '2026-06-30_NED_MAR',
    homeTeam: const Team(fifaCode: 'NED', isoCode: 'nl', name: 'Netherlands'),
    awayTeam: const Team(fifaCode: 'MAR', isoCode: 'ma', name: 'Morocco'),
    kickoffTime: DateTime.utc(2026, 6, 30, 1, 0),
    round: 'Round of 32',
    ground: 'Monterrey (Guadalupe)',
    status: GameStatus.upcoming,
  ),

  // Ivory Coast vs Norway · Tue 30 Jun 2026, 20:00 IL (17:00 UTC) · Arlington
  Game(
    id: '2026-06-30_CIV_NOR',
    homeTeam: const Team(fifaCode: 'CIV', isoCode: 'ci', name: 'Ivory Coast'),
    awayTeam: const Team(fifaCode: 'NOR', isoCode: 'no', name: 'Norway'),
    kickoffTime: DateTime.utc(2026, 6, 30, 17, 0),
    round: 'Round of 32',
    ground: 'Arlington',
    status: GameStatus.upcoming,
  ),

  // France vs Sweden · Wed 1 Jul 2026, 00:00 IL = Tue 30 Jun 21:00 UTC
  //   · New York/New Jersey (East Rutherford)
  Game(
    id: '2026-06-30_FRA_SWE',
    homeTeam: const Team(fifaCode: 'FRA', isoCode: 'fr', name: 'France'),
    awayTeam: const Team(fifaCode: 'SWE', isoCode: 'se', name: 'Sweden'),
    kickoffTime: DateTime.utc(2026, 6, 30, 21, 0),
    round: 'Round of 32',
    ground: 'New York/New Jersey (East Rutherford)',
    status: GameStatus.upcoming,
  ),
];

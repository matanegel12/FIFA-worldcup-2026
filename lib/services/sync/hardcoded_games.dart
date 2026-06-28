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
/// IMPORTANT — two rules that prevent duplicate cards:
///  1. kickoffTime is stored in **UTC**. All kickoffs we receive are in Israel
///     time (UTC+3), so subtract 3 hours to get the UTC value.
///  2. The id must use the **venue's local match date** (the openfootball feed's
///     `date` field for that slot), NOT the UTC date. When the feed later fills in
///     the real teams it generates `localDate_HOME_AWAY`; matching that id makes
///     the two writes merge into one document instead of creating a second card.
///     For late-night games the local date is often the day before the UTC date
///     (e.g. 04:00 IL = 01:00 UTC = the previous evening in a UTC-6 venue).
/// Format: `YYYY-MM-DD_HOME_AWAY`.
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

  // NOTE: Netherlands vs Morocco is intentionally NOT hardcoded — the openfootball
  // feed already provides it (local date 2026-06-29, id 2026-06-29_NED_MAR). A
  // hardcoded copy keyed on the UTC date (2026-06-30) created a duplicate card.
  // Only fixtures the feed still lists with placeholder teams belong here.

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

  // Mexico vs Ecuador · Wed 1 Jul 2026, 04:00 IL (2026-07-01 01:00 UTC) · Mexico City
  // Feed local date 2026-06-30 (kickoff is the previous evening locally).
  Game(
    id: '2026-06-30_MEX_ECU',
    homeTeam: const Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico'),
    awayTeam: const Team(fifaCode: 'ECU', isoCode: 'ec', name: 'Ecuador'),
    kickoffTime: DateTime.utc(2026, 7, 1, 1, 0),
    round: 'Round of 32',
    ground: 'Mexico City',
    status: GameStatus.upcoming,
  ),

  // England vs DR Congo · Wed 1 Jul 2026, 19:00 IL (2026-07-01 16:00 UTC) · Atlanta
  Game(
    id: '2026-07-01_ENG_COD',
    homeTeam: const Team(fifaCode: 'ENG', isoCode: 'gb-eng', name: 'England'),
    awayTeam: const Team(fifaCode: 'COD', isoCode: 'cd', name: 'DR Congo'),
    kickoffTime: DateTime.utc(2026, 7, 1, 16, 0),
    round: 'Round of 32',
    ground: 'Atlanta',
    status: GameStatus.upcoming,
  ),

  // Belgium vs Senegal · Wed 1 Jul 2026, 23:00 IL (2026-07-01 20:00 UTC) · Seattle
  Game(
    id: '2026-07-01_BEL_SEN',
    homeTeam: const Team(fifaCode: 'BEL', isoCode: 'be', name: 'Belgium'),
    awayTeam: const Team(fifaCode: 'SEN', isoCode: 'sn', name: 'Senegal'),
    kickoffTime: DateTime.utc(2026, 7, 1, 20, 0),
    round: 'Round of 32',
    ground: 'Seattle',
    status: GameStatus.upcoming,
  ),

  // USA vs Bosnia & Herzegovina · Thu 2 Jul 2026, 03:00 IL (2026-07-02 00:00 UTC)
  //   · San Francisco Bay Area (Santa Clara). Feed local date 2026-07-01.
  Game(
    id: '2026-07-01_USA_BIH',
    homeTeam: const Team(fifaCode: 'USA', isoCode: 'us', name: 'USA'),
    awayTeam:
        const Team(fifaCode: 'BIH', isoCode: 'ba', name: 'Bosnia & Herzegovina'),
    kickoffTime: DateTime.utc(2026, 7, 2, 0, 0),
    round: 'Round of 32',
    ground: 'San Francisco Bay Area (Santa Clara)',
    status: GameStatus.upcoming,
  ),

  // Spain vs Austria · Thu 2 Jul 2026, 22:00 IL (2026-07-02 19:00 UTC) · Los Angeles
  Game(
    id: '2026-07-02_ESP_AUT',
    homeTeam: const Team(fifaCode: 'ESP', isoCode: 'es', name: 'Spain'),
    awayTeam: const Team(fifaCode: 'AUT', isoCode: 'at', name: 'Austria'),
    kickoffTime: DateTime.utc(2026, 7, 2, 19, 0),
    round: 'Round of 32',
    ground: 'Los Angeles (Inglewood)',
    status: GameStatus.upcoming,
  ),

  // Portugal vs Croatia · Fri 3 Jul 2026, 02:00 IL (2026-07-02 23:00 UTC) · Toronto
  Game(
    id: '2026-07-02_POR_CRO',
    homeTeam: const Team(fifaCode: 'POR', isoCode: 'pt', name: 'Portugal'),
    awayTeam: const Team(fifaCode: 'CRO', isoCode: 'hr', name: 'Croatia'),
    kickoffTime: DateTime.utc(2026, 7, 2, 23, 0),
    round: 'Round of 32',
    ground: 'Toronto',
    status: GameStatus.upcoming,
  ),

  // Switzerland vs Algeria · Fri 3 Jul 2026, 06:00 IL (2026-07-03 03:00 UTC)
  //   · Vancouver. Feed local date 2026-07-02.
  Game(
    id: '2026-07-02_SUI_ALG',
    homeTeam: const Team(fifaCode: 'SUI', isoCode: 'ch', name: 'Switzerland'),
    awayTeam: const Team(fifaCode: 'ALG', isoCode: 'dz', name: 'Algeria'),
    kickoffTime: DateTime.utc(2026, 7, 3, 3, 0),
    round: 'Round of 32',
    ground: 'Vancouver',
    status: GameStatus.upcoming,
  ),

  // Australia vs Egypt · Fri 3 Jul 2026, 21:00 IL (2026-07-03 18:00 UTC) · Dallas (Arlington)
  Game(
    id: '2026-07-03_AUS_EGY',
    homeTeam: const Team(fifaCode: 'AUS', isoCode: 'au', name: 'Australia'),
    awayTeam: const Team(fifaCode: 'EGY', isoCode: 'eg', name: 'Egypt'),
    kickoffTime: DateTime.utc(2026, 7, 3, 18, 0),
    round: 'Round of 32',
    ground: 'Dallas (Arlington)',
    status: GameStatus.upcoming,
  ),

  // Argentina vs Cape Verde · Sat 4 Jul 2026, 01:00 IL (2026-07-03 22:00 UTC)
  //   · Miami (Miami Gardens). Feed local date 2026-07-03.
  Game(
    id: '2026-07-03_ARG_CPV',
    homeTeam: const Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina'),
    awayTeam: const Team(fifaCode: 'CPV', isoCode: 'cv', name: 'Cape Verde'),
    kickoffTime: DateTime.utc(2026, 7, 3, 22, 0),
    round: 'Round of 32',
    ground: 'Miami (Miami Gardens)',
    status: GameStatus.upcoming,
  ),

  // Colombia vs Ghana · Sat 4 Jul 2026, 04:30 IL (2026-07-04 01:30 UTC)
  //   · Kansas City. Feed local date 2026-07-03.
  Game(
    id: '2026-07-03_COL_GHA',
    homeTeam: const Team(fifaCode: 'COL', isoCode: 'co', name: 'Colombia'),
    awayTeam: const Team(fifaCode: 'GHA', isoCode: 'gh', name: 'Ghana'),
    kickoffTime: DateTime.utc(2026, 7, 4, 1, 30),
    round: 'Round of 32',
    ground: 'Kansas City',
    status: GameStatus.upcoming,
  ),
];

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/game.dart';
import '../../models/team.dart';

/// Fetches World Cup 2026 fixtures and results from the openfootball public JSON.
/// This is the only place in the app that knows the API URL or response format.
///
/// Source: https://github.com/openfootball/worldcup.json
class WorldCupApiClient {
  static const String _url =
      'https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json';

  final http.Client _client;

  /// [client] can be injected in tests to avoid real HTTP calls.
  WorldCupApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Game>> fetchGames() async {
    final response = await _client.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch games (HTTP ${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final matches = json['matches'] as List<dynamic>;
    return matches
        .map((m) => _parseGame(m as Map<String, dynamic>))
        .whereType<Game>() // drops null (knockout stage placeholders)
        .toList();
  }

  // ── Parsing ──────────────────────────────────────────────────────────────────

  /// Returns null for knockout stage entries whose team names are placeholders
  /// like "1A" or "W100" — those are not real teams yet.
  Game? _parseGame(Map<String, dynamic> match) {
    final homeTeam = _teamFromName(match['team1'] as String);
    final awayTeam = _teamFromName(match['team2'] as String);
    if (homeTeam == null || awayTeam == null) return null;

    final kickoffTime = _parseKickoff(
      match['date'] as String,
      match['time'] as String? ?? '00:00',
    );

    final score = match['score'] as Map<String, dynamic>?;
    final isFinished = score != null;

    int? homeScore;
    int? awayScore;
    DateTime? finishedAt;

    if (isFinished) {
      final ft = score!['ft'] as List<dynamic>;
      homeScore = ft[0] as int;
      awayScore = ft[1] as int;
      // finishedAt is intentionally null here — the API doesn't tell us when
      // the game ended. Our system sets it precisely when recording results.
    }

    final dateStr = match['date'] as String;

    return Game(
      // Stable ID built from date + FIFA codes — survives API reorders.
      id: '${dateStr}_${homeTeam.fifaCode}_${awayTeam.fifaCode}',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      kickoffTime: kickoffTime,
      homeScore: homeScore,
      awayScore: awayScore,
      status: isFinished ? GameStatus.finished : GameStatus.upcoming,
      finishedAt: finishedAt,
      round: match['round'] as String? ?? '',
      ground: match['ground'] as String? ?? '',
    );
  }

  /// Parses "13:00 UTC-6" or "19:00" into a UTC DateTime.
  ///
  /// The 2026 fixtures use local times with UTC offsets (e.g. UTC-6 for
  /// Mexico City). UTC = local time − offset, so UTC-6 means +6 hours.
  DateTime _parseKickoff(String date, String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    int offsetHours = 0;
    if (parts.length > 1 && parts[1].startsWith('UTC')) {
      final offsetStr = parts[1].substring(3); // strips "UTC" → "-6" or "+5"
      if (offsetStr.isNotEmpty) offsetHours = int.parse(offsetStr);
    }

    final dateParts = date.split('-');
    final local = DateTime.utc(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      hour,
      minute,
    );
    // Subtract the offset to get UTC (UTC-6: subtract -6 = add 6).
    return local.subtract(Duration(hours: offsetHours));
  }

  Team? _teamFromName(String name) {
    final data = _teamData[name];
    if (data == null) return null;
    return Team(fifaCode: data[0], isoCode: data[1], name: name);
  }

  // ── Team name → [fifaCode, isoCode] ─────────────────────────────────────────
  // Covers all 48 group-stage participants for World Cup 2026.

  static const Map<String, List<String>> _teamData = {
    // Group A
    'Mexico': ['MEX', 'mx'],
    'South Africa': ['RSA', 'za'],
    'South Korea': ['KOR', 'kr'],
    'Czech Republic': ['CZE', 'cz'],
    // Group B
    'Canada': ['CAN', 'ca'],
    'Bosnia & Herzegovina': ['BIH', 'ba'],
    'Qatar': ['QAT', 'qa'],
    'Switzerland': ['SUI', 'ch'],
    // Group C
    'Germany': ['GER', 'de'],
    'Japan': ['JPN', 'jp'],
    'Scotland': ['SCO', 'gb-sct'],
    'Paraguay': ['PAR', 'py'],
    // Group D
    'Portugal': ['POR', 'pt'],
    'Iraq': ['IRQ', 'iq'],
    'DR Congo': ['COD', 'cd'],
    'Ecuador': ['ECU', 'ec'],
    // Group E
    'France': ['FRA', 'fr'],
    'Saudi Arabia': ['KSA', 'sa'],
    'Ivory Coast': ['CIV', 'ci'],
    'Uzbekistan': ['UZB', 'uz'],
    // Group F
    'Brazil': ['BRA', 'br'],
    'Norway': ['NOR', 'no'],
    'Algeria': ['ALG', 'dz'],
    'Iran': ['IRN', 'ir'],
    // Group G
    'Spain': ['ESP', 'es'],
    'Croatia': ['CRO', 'hr'],
    'Tunisia': ['TUN', 'tn'],
    'New Zealand': ['NZL', 'nz'],
    // Group H
    'Netherlands': ['NED', 'nl'],
    'Senegal': ['SEN', 'sn'],
    'Curaçao': ['CUW', 'cw'],
    'Australia': ['AUS', 'au'],
    // Group I
    'Argentina': ['ARG', 'ar'],
    'England': ['ENG', 'gb-eng'],
    'Jordan': ['JOR', 'jo'],
    'Egypt': ['EGY', 'eg'],
    // Group J
    'USA': ['USA', 'us'],
    'Turkey': ['TUR', 'tr'],
    'Ghana': ['GHA', 'gh'],
    'Cape Verde': ['CPV', 'cv'],
    // Group K
    'Colombia': ['COL', 'co'],
    'Belgium': ['BEL', 'be'],
    'Morocco': ['MAR', 'ma'],
    'Haiti': ['HAI', 'ht'],
    // Group L
    'Austria': ['AUT', 'at'],
    'Uruguay': ['URU', 'uy'],
    'Sweden': ['SWE', 'se'],
    'Panama': ['PAN', 'pa'],
  };
}

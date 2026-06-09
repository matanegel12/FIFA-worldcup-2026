import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../models/game.dart';
import '../../models/team.dart';
import 'secrets.dart';
import 'team_mappings.dart';

class ApiFootballClient {
  static const String _leagueId = '1';
  // Free API plan supports 2022–2024; update to '2026' once upgraded.
  static const String _season = '2022';

  final http.Client _httpClient;

  ApiFootballClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'x-apisports-key': kApiFootballKey,
        'x-apisports-host': kApiFootballHost,
      };

  Future<List<Game>> fetchAllFixtures() async {
    final Uri url = Uri.parse(
      '$kApiFootballBaseUrl/fixtures?league=$_leagueId&season=$_season',
    );

    print('[ApiFootballClient] calling: $url');
    final http.Response response = await _httpClient.get(
      url,
      headers: _headers,
    );
    print('[ApiFootballClient] response status: ${response.statusCode}');
    print('[ApiFootballClient] response body preview: ${response.body.substring(0, min(200, response.body.length))}');

    if (response.statusCode != 200) {
      throw Exception('API-Football error: ${response.statusCode}');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> fixtures = json['response'] as List<dynamic>;

    return fixtures
        .map((dynamic f) => _parseFixture(f as Map<String, dynamic>))
        .whereType<Game>()
        .toList();
  }

  Game? _parseFixture(Map<String, dynamic> fixture) {
    print('[ApiFootballClient] parsing fixture: ${fixture['fixture']?['id']}');
    try {
      final Map<String, dynamic> fixtureData =
          fixture['fixture'] as Map<String, dynamic>;
      final Map<String, dynamic> teams =
          fixture['teams'] as Map<String, dynamic>;
      final Map<String, dynamic> goals =
          fixture['goals'] as Map<String, dynamic>;
      final Map<String, dynamic> league =
          fixture['league'] as Map<String, dynamic>;

      final String homeApiName =
          (teams['home'] as Map<String, dynamic>)['name'] as String;
      final String awayApiName =
          (teams['away'] as Map<String, dynamic>)['name'] as String;

      final Team homeTeam = teamFromApiName(homeApiName);
      final Team awayTeam = teamFromApiName(awayApiName);

      final String statusShort =
          (fixtureData['status'] as Map<String, dynamic>)['short'] as String;
      final GameStatus status = _parseStatus(statusShort);

      final int? homeScore = goals['home'] as int?;
      final int? awayScore = goals['away'] as int?;

      final DateTime kickoffTime =
          DateTime.parse(fixtureData['date'] as String).toUtc();

      final DateTime? finishedAt = status == GameStatus.finished
          ? kickoffTime.add(const Duration(hours: 2))
          : null;

      final String round = league['round'] as String? ?? '';
      final String ground =
          (fixtureData['venue'] as Map<String, dynamic>?)?['city']
                  as String? ??
              '';

      return Game(
        id: fixtureData['id'].toString(),
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        kickoffTime: kickoffTime,
        round: round,
        ground: ground,
        homeScore: homeScore,
        awayScore: awayScore,
        status: status,
        finishedAt: finishedAt,
      );
    } catch (e) {
      print('[ApiFootballClient] failed to parse fixture: $e');
      return null;
    }
  }

  GameStatus _parseStatus(String short) {
    switch (short) {
      case 'FT':
      case 'AET':
      case 'PEN':
        return GameStatus.finished;
      default:
        return GameStatus.upcoming;
    }
  }
}

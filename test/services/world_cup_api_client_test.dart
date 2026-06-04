import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/services/api/world_cup_api_client.dart';

// Mirrors the real openfootball 2026 format exactly.
const _sampleJson = '''
{
  "name": "World Cup 2026",
  "matches": [
    {
      "round": "Matchday 1",
      "date": "2026-06-11",
      "time": "13:00 UTC-6",
      "team1": "Mexico",
      "team2": "South Africa",
      "group": "Group A",
      "ground": "Mexico City"
    },
    {
      "round": "Matchday 1",
      "date": "2026-06-11",
      "time": "19:00 UTC-6",
      "team1": "Brazil",
      "team2": "Argentina",
      "score": { "ft": [2, 1], "ht": [1, 0] },
      "group": "Group F",
      "ground": "Los Angeles"
    },
    {
      "round": "Matchday 1",
      "date": "2026-06-12",
      "time": "15:00 UTC-4",
      "team1": "France",
      "team2": "Germany",
      "score": { "ft": [0, 0], "ht": [0, 0] },
      "group": "Group G",
      "ground": "Atlanta"
    },
    {
      "round": "Round of 32",
      "date": "2026-07-04",
      "time": "15:00 UTC-4",
      "team1": "1A",
      "team2": "2B",
      "ground": "Atlanta"
    }
  ]
}
''';

WorldCupApiClient _clientWith(String body, {int statusCode = 200}) =>
    WorldCupApiClient(
      client: MockClient((_) async => http.Response(body, statusCode)),
    );

void main() {
  group('WorldCupApiClient.fetchGames', () {
    test('returns only group stage games — skips knockout placeholders', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      expect(games.length, 3); // "1A vs 2B" is skipped
    });

    test('upcoming game has null scores and upcoming status', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final upcoming = games.first; // Mexico vs South Africa

      expect(upcoming.homeScore, isNull);
      expect(upcoming.awayScore, isNull);
      expect(upcoming.status, GameStatus.upcoming);
      expect(upcoming.finishedAt, isNull);
      expect(upcoming.isFinished, isFalse);
    });

    test('finished game has correct scores and outcome', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final finished = games[1]; // Brazil 2–1 Argentina

      expect(finished.homeScore, 2);
      expect(finished.awayScore, 1);
      expect(finished.status, GameStatus.finished);
      expect(finished.outcome, Prediction.teamAWins);
    });

    test('draw game has correct outcome', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final draw = games[2]; // France 0–0 Germany

      expect(draw.outcome, Prediction.draw);
    });

    test('kickoffTime is converted from local timezone to UTC', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final game = games.first; // "13:00 UTC-6" → 19:00 UTC

      expect(game.kickoffTime.isUtc, isTrue);
      expect(game.kickoffTime.hour, 19); // 13 + 6 = 19
    });

    test('UTC-4 timezone converts correctly', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final game = games[2]; // "15:00 UTC-4" → 19:00 UTC

      expect(game.kickoffTime.hour, 19); // 15 + 4 = 19
    });

    test('teams have correct fifaCode, isoCode and name', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final home = games.first.homeTeam; // Mexico

      expect(home.fifaCode, 'MEX');
      expect(home.isoCode, 'mx');
      expect(home.name, 'Mexico');
    });

    test('flagUrl is built correctly from isoCode', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      expect(games.first.homeTeam.flagUrl, 'https://flagcdn.com/w80/mx.png');
    });

    test('game id is date_homeFifa_awayFifa', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      expect(games[0].id, '2026-06-11_MEX_RSA');
      expect(games[1].id, '2026-06-11_BRA_ARG');
    });

    test('finishedAt is null from API — set by our system when recording results', () async {
      final games = await _clientWith(_sampleJson).fetchGames();
      final finished = games[1]; // Brazil 2–1 Argentina

      expect(finished.finishedAt, isNull);
    });

    test('throws when server returns non-200 status', () {
      expect(
        () => _clientWith('', statusCode: 500).fetchGames(),
        throwsException,
      );
    });
  });
}

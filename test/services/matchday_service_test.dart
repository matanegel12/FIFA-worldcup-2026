import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/matchday_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

Game _game(String id, String round) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2026, 6, 18, 15, 0),
      status: GameStatus.upcoming,
      round: round,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('sortedRounds', () {
    test('returns empty list when games list is empty', () {
      expect(sortedRounds([]), isEmpty);
    });

    test('returns single round for a single game', () {
      expect(sortedRounds([_game('g1', 'Matchday 1')]), ['Matchday 1']);
    });

    test('deduplicates rounds from multiple games in the same round', () {
      final List<Game> games = [
        _game('g1', 'Matchday 1'),
        _game('g2', 'Matchday 1'),
      ];
      expect(sortedRounds(games), ['Matchday 1']);
    });

    test('sorts rounds by embedded number ascending', () {
      final List<Game> games = [
        _game('g3', 'Matchday 14'),
        _game('g1', 'Matchday 1'),
        _game('g2', 'Matchday 8'),
      ];
      expect(sortedRounds(games), ['Matchday 1', 'Matchday 8', 'Matchday 14']);
    });

    test('sorts by embedded number not alphabetically', () {
      // Alphabetically "Matchday 9" > "Matchday 14" but numerically 9 < 14.
      final List<Game> games = [
        _game('g1', 'Matchday 2'),
        _game('g2', 'Matchday 9'),
        _game('g3', 'Matchday 14'),
      ];
      expect(sortedRounds(games), ['Matchday 2', 'Matchday 9', 'Matchday 14']);
    });

    test('games with empty round string are ignored', () {
      final List<Game> games = [
        _game('gx', ''),
        _game('g1', 'Matchday 1'),
        _game('g2', 'Matchday 8'),
      ];
      expect(sortedRounds(games), ['Matchday 1', 'Matchday 8']);
    });
  });
}

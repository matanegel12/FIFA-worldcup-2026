import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/matchday_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

Game _game(String id, String round, DateTime kickoffTime) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: kickoffTime,
      status: GameStatus.upcoming,
      round: round,
    );

DateTime _d(int day) => DateTime.utc(2026, 6, day, 15, 0);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('sortedRounds', () {
    test('returns empty list when games list is empty', () {
      expect(sortedRounds([]), isEmpty);
    });

    test('returns single round for a single game', () {
      expect(sortedRounds([_game('g1', 'Matchday 1', _d(1))]), ['Matchday 1']);
    });

    test('deduplicates rounds from multiple games in the same round', () {
      final List<Game> games = [
        _game('g1', 'Matchday 1', _d(1)),
        _game('g2', 'Matchday 1', _d(1)),
      ];
      expect(sortedRounds(games), ['Matchday 1']);
    });

    test('sorts rounds by earliest kickoff time ascending', () {
      final List<Game> games = [
        _game('g3', 'Matchday 14', _d(14)),
        _game('g1', 'Matchday 1', _d(1)),
        _game('g2', 'Matchday 8', _d(8)),
      ];
      expect(sortedRounds(games), ['Matchday 1', 'Matchday 8', 'Matchday 14']);
    });

    test('a round is ordered by its earliest game when games are out of order', () {
      final List<Game> games = [
        _game('g1', 'Matchday 2', _d(9)),
        _game('g2', 'Matchday 2', _d(2)), // earlier — decides the round's position
        _game('g3', 'Matchday 1', _d(5)),
      ];
      expect(sortedRounds(games), ['Matchday 2', 'Matchday 1']);
    });

    test('knockout rounds sort by kickoff time, not the embedded number', () {
      // Round of 32 (32) kicks off before Round of 16 (16) — a naive sort by
      // the number in the name would (wrongly) put Round of 16 first.
      final List<Game> games = [
        _game('g2', 'Round of 16', _d(20)),
        _game('g1', 'Round of 32', _d(10)),
      ];
      expect(sortedRounds(games), ['Round of 32', 'Round of 16']);
    });

    test('games with empty round string are ignored', () {
      final List<Game> games = [
        _game('gx', '', _d(1)),
        _game('g1', 'Matchday 1', _d(2)),
        _game('g2', 'Matchday 8', _d(3)),
      ];
      expect(sortedRounds(games), ['Matchday 1', 'Matchday 8']);
    });
  });
}

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
  group('isMatchdayUnlocked — empty list', () {
    test('returns false when futureGames is empty', () {
      expect(isMatchdayUnlocked('Matchday 1', []), isFalse);
    });
  });

  group('isMatchdayUnlocked — single matchday', () {
    test('the only matchday in futureGames is unlocked', () {
      final List<Game> future = [
        _game('g1', 'Matchday 1'),
        _game('g2', 'Matchday 1'),
      ];
      expect(isMatchdayUnlocked('Matchday 1', future), isTrue);
    });

    test('a matchday not present in futureGames is locked', () {
      final List<Game> future = [_game('g1', 'Matchday 8')];
      expect(isMatchdayUnlocked('Matchday 1', future), isFalse);
    });
  });

  group('isMatchdayUnlocked — multiple matchdays', () {
    test('lowest round number is unlocked, others are locked', () {
      final List<Game> future = [
        _game('g1', 'Matchday 1'),
        _game('g2', 'Matchday 8'),
        _game('g3', 'Matchday 14'),
      ];

      expect(isMatchdayUnlocked('Matchday 1', future), isTrue);
      expect(isMatchdayUnlocked('Matchday 8', future), isFalse);
      expect(isMatchdayUnlocked('Matchday 14', future), isFalse);
    });

    test('Matchday 8 unlocks when Matchday 1 games are no longer in futureGames', () {
      // Matchday 1 kicked off → caller removes them from futureGames.
      final List<Game> future = [
        _game('g3', 'Matchday 8'),
        _game('g4', 'Matchday 8'),
      ];
      expect(isMatchdayUnlocked('Matchday 8', future), isTrue);
    });

    test('Matchday 14 unlocks when only Matchday 14 games remain', () {
      final List<Game> future = [_game('g5', 'Matchday 14')];
      expect(isMatchdayUnlocked('Matchday 14', future), isTrue);
    });
  });

  group('isMatchdayUnlocked — edge cases', () {
    test('returns false for an unknown matchday string', () {
      final List<Game> future = [_game('g1', 'Matchday 1')];
      expect(isMatchdayUnlocked('Matchday 99', future), isFalse);
    });

    test('games with empty round string are ignored', () {
      final List<Game> future = <Game>[
        _game('gx', ''),           // empty round — ignored
        _game('g1', 'Matchday 1'),
        _game('g3', 'Matchday 8'),
      ];
      expect(isMatchdayUnlocked('Matchday 1', future), isTrue);
      expect(isMatchdayUnlocked('Matchday 8', future), isFalse);
    });
  });

  group('isMatchdayUnlocked — non-sequential round numbers', () {
    test('sorts by embedded number, not alphabetically', () {
      // "Matchday 9" > "Matchday 14" alphabetically but 9 < 14 numerically.
      // Numerically: Matchday 2 < Matchday 9 < Matchday 14.
      final List<Game> future = [
        _game('g1', 'Matchday 2'),
        _game('g2', 'Matchday 9'),
        _game('g3', 'Matchday 14'),
      ];
      expect(isMatchdayUnlocked('Matchday 2', future), isTrue);
      expect(isMatchdayUnlocked('Matchday 9', future), isFalse);
      expect(isMatchdayUnlocked('Matchday 14', future), isFalse);
    });
  });
}

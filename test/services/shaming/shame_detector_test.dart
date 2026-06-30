import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/shaming/shame_detector.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

const Team _civ = Team(fifaCode: 'CIV', isoCode: 'ci', name: 'Ivory Coast');
const Team _nor = Team(fifaCode: 'NOR', isoCode: 'no', name: 'Norway');

final DateTime _kickoff = DateTime.utc(2026, 6, 30, 17, 0);

Game _game(String id) => Game(
      id: id,
      homeTeam: _civ,
      awayTeam: _nor,
      kickoffTime: _kickoff,
      status: GameStatus.upcoming,
    );

Map<String, Game> _games(String id) => {id: _game(id)};

const Map<String, String> _names = {'u1': 'Adel', 'u2': 'Dana'};

TimedGuess _guess(String userId, String gameId, DateTime submittedAt) =>
    TimedGuess(
      userId: userId,
      gameId: gameId,
      prediction: Prediction.teamBWins,
      submittedAt: submittedAt,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('detectLateGuesses', () {
    test('flags a guess submitted after kickoff', () {
      final result = detectLateGuesses(
        guesses: [_guess('u1', 'g1', _kickoff.add(const Duration(minutes: 5)))],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );

      expect(result, hasLength(1));
      expect(result.first.userId, 'u1');
      expect(result.first.displayName, 'Adel');
      expect(result.first.gameLabel, 'Ivory Coast vs Norway');
      expect(result.first.lateBy, const Duration(minutes: 5));
    });

    test('does NOT flag a guess submitted before kickoff', () {
      final result = detectLateGuesses(
        guesses: [
          _guess('u1', 'g1', _kickoff.subtract(const Duration(minutes: 1)))
        ],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );
      expect(result, isEmpty);
    });

    test('does NOT flag a guess submitted exactly at kickoff (boundary)', () {
      final result = detectLateGuesses(
        guesses: [_guess('u1', 'g1', _kickoff)],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );
      expect(result, isEmpty);
    });

    test('skips a guess for an unknown game', () {
      final result = detectLateGuesses(
        guesses: [
          _guess('u1', 'missing', _kickoff.add(const Duration(hours: 1)))
        ],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );
      expect(result, isEmpty);
    });

    test('uses a fallback name when the user is unknown', () {
      final result = detectLateGuesses(
        guesses: [_guess('ghost', 'g1', _kickoff.add(const Duration(minutes: 9)))],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );
      expect(result.single.displayName, 'Unknown player');
    });

    test('sorts latest offenders first', () {
      final result = detectLateGuesses(
        guesses: [
          _guess('u1', 'g1', _kickoff.add(const Duration(minutes: 5))),
          _guess('u2', 'g1', _kickoff.add(const Duration(minutes: 30))),
        ],
        gamesById: _games('g1'),
        displayNamesByUserId: _names,
      );
      expect(result.map((e) => e.userId).toList(), ['u2', 'u1']);
    });

    test('empty input yields empty output', () {
      expect(
        detectLateGuesses(
          guesses: const [],
          gamesById: _games('g1'),
          displayNamesByUserId: _names,
        ),
        isEmpty,
      );
    });
  });
}

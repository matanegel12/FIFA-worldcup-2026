import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/score_summary.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/scoring/scoring_calculator.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

const mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const france = Team(fifaCode: 'FRA', isoCode: 'fr', name: 'France');
const germany = Team(fifaCode: 'GER', isoCode: 'de', name: 'Germany');

/// A finished game with a known result. [round] controls which match day
/// the game belongs to for set-bonus grouping.
Game _finishedGame({
  required String id,
  required int homeScore,
  required int awayScore,
  String round = 'Matchday 1',
}) =>
    Game(
      id: id,
      homeTeam: mexico,
      awayTeam: brazil,
      kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
      homeScore: homeScore,
      awayScore: awayScore,
      status: GameStatus.finished,
      finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      round: round,
    );

/// A finished knockout game (kickoff at/after the cutoff → +2 rules).
/// Defaults to exactly the cutoff instant to also cover the boundary.
Game _knockoutGame({
  required String id,
  required int homeScore,
  required int awayScore,
  String round = 'Round of 32',
  DateTime? kickoffTime,
}) =>
    Game(
      id: id,
      homeTeam: france,
      awayTeam: germany,
      kickoffTime: kickoffTime ?? DateTime.utc(2026, 6, 28, 19, 0), // cutoff
      homeScore: homeScore,
      awayScore: awayScore,
      status: GameStatus.finished,
      finishedAt: DateTime.utc(2026, 6, 28, 21, 0),
      round: round,
    );

/// A guess submitted by the test user.
Guess _guess(String gameId, Prediction prediction) => Guess(
      userId: 'uid-test',
      gameId: gameId,
      prediction: prediction,
    );

ScoreSummary _calc(List<Game> games, List<Guess> guesses) => calculate(
      userId: 'uid-test',
      finishedGames: games,
      userGuesses: guesses,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('individual game scoring', () {
    // Two games in the same match day — one guessed correctly, one not — so
    // it is never a perfect match day. This isolates the +1 rule from +2 bonus.

    test('+1 for a correct prediction (teamAWins)', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1); // teamBWins
      // Only guess game1 — game2 missed → not a perfect match day → no set bonus.
      final summary = _calc([game1, game2], [_guess('g1', Prediction.teamAWins)]);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('+1 for a correct prediction (teamBWins)', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 0, awayScore: 3); // teamBWins
      final game2 = _finishedGame(id: 'g2', homeScore: 1, awayScore: 0); // teamAWins
      final summary = _calc([game1, game2], [_guess('g1', Prediction.teamBWins)]);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('+1 for a correct prediction (draw)', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 1, awayScore: 1); // draw
      final game2 = _finishedGame(id: 'g2', homeScore: 2, awayScore: 0); // teamAWins
      final summary = _calc([game1, game2], [_guess('g1', Prediction.draw)]);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('+0 for a wrong prediction', () {
      final game = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final summary = _calc([game], [_guess('g1', Prediction.teamBWins)]);

      expect(summary.correctGuesses, 0);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 0);
    });

    test('+0 for a missed game (no guess submitted)', () {
      final game = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1);
      final summary = _calc([game], []); // no guesses

      expect(summary.correctGuesses, 0);
      expect(summary.totalPoints, 0);
    });
  });

  group('set bonus', () {
    test('+2 bonus when all games in the match day are correct', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 0); // draw
      // Both in 'Matchday 1' (default) — both guessed correctly.
      final guesses = [
        _guess('g1', Prediction.teamAWins),
        _guess('g2', Prediction.draw),
      ];

      final summary = _calc([game1, game2], guesses);

      expect(summary.correctGuesses, 2);
      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 4); // 2 + 2
    });

    test('no set bonus when one game in the match day is wrong', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 0); // draw
      final guesses = [
        _guess('g1', Prediction.teamAWins),
        _guess('g2', Prediction.teamBWins), // wrong
      ];

      final summary = _calc([game1, game2], guesses);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('no set bonus when one game in the match day was missed', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1);
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1);
      final guesses = [
        _guess('g1', Prediction.teamAWins),
        // g2 not guessed
      ];

      final summary = _calc([game1, game2], guesses);

      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('match day with a single game awards +2 when that game is correct', () {
      final game = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      final summary = _calc([game], [_guess('g1', Prediction.teamAWins)]);

      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 3); // 1 + 2
    });
  });

  group('multiple match days', () {
    test('bonus only on perfect match days — imperfect ones earn no bonus', () {
      // Matchday 1: two games, both correct → set bonus
      final md1game1 = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0, round: 'Matchday 1');
      final md1game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 0, round: 'Matchday 1');
      // Matchday 2: one correct, one wrong → no set bonus
      final md2game1 = _finishedGame(id: 'g3', homeScore: 3, awayScore: 0, round: 'Matchday 2');
      final md2game2 = _finishedGame(id: 'g4', homeScore: 1, awayScore: 2, round: 'Matchday 2');

      final guesses = [
        _guess('g1', Prediction.teamAWins), // ✓
        _guess('g2', Prediction.draw),      // ✓
        _guess('g3', Prediction.teamAWins), // ✓
        _guess('g4', Prediction.teamAWins), // ✗ (teamBWins)
      ];

      final summary = _calc(
        [md1game1, md1game2, md2game1, md2game2],
        guesses,
      );

      expect(summary.correctGuesses, 3);
      expect(summary.setBonusCount, 1);   // only Matchday 1
      expect(summary.totalPoints, 5);     // 3 + 2
    });

    test('two perfect match days each earn +2', () {
      final md1 = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0, round: 'Matchday 1');
      final md2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1, round: 'Matchday 2');

      final summary = _calc(
        [md1, md2],
        [
          _guess('g1', Prediction.teamAWins),
          _guess('g2', Prediction.teamBWins),
        ],
      );

      expect(summary.setBonusCount, 2);
      expect(summary.totalPoints, 6); // 2 + 4
    });

    test('+2 when all games in Matchday 1 are correct', () {
      final md1game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 0, round: 'Matchday 1');
      final md1game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1, round: 'Matchday 1');

      final summary = _calc(
        [md1game1, md1game2],
        [
          _guess('g1', Prediction.teamAWins),
          _guess('g2', Prediction.teamBWins),
        ],
      );

      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 4); // 2 correct + 2 bonus
    });

    test('no bonus when only some games in Matchday 1 are correct', () {
      final md1game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 0, round: 'Matchday 1');
      final md1game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1, round: 'Matchday 1');

      final summary = _calc(
        [md1game1, md1game2],
        [
          _guess('g1', Prediction.teamAWins), // correct
          _guess('g2', Prediction.teamAWins), // wrong (teamBWins)
        ],
      );

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('+2 for Matchday 1 and +2 for Matchday 2 independently', () {
      final md1 = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0, round: 'Matchday 1');
      final md2 = _finishedGame(id: 'g2', homeScore: 2, awayScore: 2, round: 'Matchday 2');

      final summary = _calc(
        [md1, md2],
        [
          _guess('g1', Prediction.teamAWins),
          _guess('g2', Prediction.draw),
        ],
      );

      expect(summary.correctGuesses, 2);
      expect(summary.setBonusCount, 2);
      expect(summary.totalPoints, 6); // 2 correct + 4 bonus
    });

    test('mixed: correct on Matchday 1, partial on Matchday 2 — only one +2', () {
      final md1 = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0, round: 'Matchday 1');
      final md2a = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1, round: 'Matchday 2');
      final md2b = _finishedGame(id: 'g3', homeScore: 1, awayScore: 1, round: 'Matchday 2');

      final summary = _calc(
        [md1, md2a, md2b],
        [
          _guess('g1', Prediction.teamAWins), // Matchday 1 correct ✓
          _guess('g2', Prediction.teamBWins), // Matchday 2 correct ✓
          _guess('g3', Prediction.teamAWins), // Matchday 2 wrong ✗
        ],
      );

      expect(summary.correctGuesses, 2);
      expect(summary.setBonusCount, 1);   // only Matchday 1
      expect(summary.totalPoints, 4);     // 2 + 2
    });
  });

  group('knockout scoring', () {
    test('+2 for a correct knockout prediction', () {
      final game = _knockoutGame(id: 'k1', homeScore: 2, awayScore: 1); // teamAWins
      final summary = _calc([game], [_guess('k1', Prediction.teamAWins)]);

      expect(summary.knockoutCorrectGuesses, 1);
      expect(summary.correctGuesses, 0); // not counted as group-stage
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 2);
    });

    test('+0 for a wrong knockout prediction', () {
      final game = _knockoutGame(id: 'k1', homeScore: 2, awayScore: 1); // teamAWins
      final summary = _calc([game], [_guess('k1', Prediction.teamBWins)]);

      expect(summary.knockoutCorrectGuesses, 0);
      expect(summary.totalPoints, 0);
    });

    test('knockout games never earn a set bonus, even a perfect round', () {
      // Two correct knockout games in the same round — no bonus, just 2+2.
      final k1 = _knockoutGame(id: 'k1', homeScore: 1, awayScore: 0);
      final k2 = _knockoutGame(id: 'k2', homeScore: 0, awayScore: 2);
      final summary = _calc([k1, k2], [
        _guess('k1', Prediction.teamAWins),
        _guess('k2', Prediction.teamBWins),
      ]);

      expect(summary.knockoutCorrectGuesses, 2);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 4); // 2 × 2, no bonus
    });

    test('a game before the cutoff still uses group-stage rules', () {
      // _finishedGame kicks off 2026-06-11, well before the cutoff.
      final game = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      final summary = _calc([game], [_guess('g1', Prediction.teamAWins)]);

      expect(summary.correctGuesses, 1);
      expect(summary.knockoutCorrectGuesses, 0);
      expect(summary.setBonusCount, 1); // single perfect group-stage round
      expect(summary.totalPoints, 3); // 1 + 2 bonus
    });

    test('mixed group-stage and knockout games score under their own rules', () {
      // Group stage: a perfect round worth 1 + 2 = 3.
      final gs = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      // Knockout: one correct worth 2.
      final ko = _knockoutGame(id: 'k1', homeScore: 0, awayScore: 1);
      final summary = _calc([gs, ko], [
        _guess('g1', Prediction.teamAWins),
        _guess('k1', Prediction.teamBWins),
      ]);

      expect(summary.correctGuesses, 1);
      expect(summary.knockoutCorrectGuesses, 1);
      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 5); // (1 + 2 bonus) + 2
    });
  });

  group('edge cases', () {
    test('user with no guesses scores 0', () {
      final game = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      final summary = _calc([game], []);

      expect(summary.totalPoints, 0);
    });

    test('no finished games scores 0', () {
      final summary = _calc([], [_guess('g1', Prediction.teamAWins)]);

      expect(summary.totalPoints, 0);
    });

    test('guesses for other users are ignored', () {
      final game = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      final otherUserGuess = Guess(
        userId: 'uid-other',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
      );

      final summary = calculate(
        userId: 'uid-test',
        finishedGames: [game],
        userGuesses: [otherUserGuess],
      );

      expect(summary.correctGuesses, 0);
    });
  });
}

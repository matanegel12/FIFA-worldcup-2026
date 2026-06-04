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

/// A finished game with a known result.
Game _finishedGame({
  required String id,
  required int homeScore,
  required int awayScore,
  DateTime? kickoffTime,
}) =>
    Game(
      id: id,
      homeTeam: mexico,
      awayTeam: brazil,
      kickoffTime: kickoffTime ?? DateTime.utc(2026, 6, 11, 15, 0),
      homeScore: homeScore,
      awayScore: awayScore,
      status: GameStatus.finished,
      finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
    );

/// A guess submitted by the test user.
Guess _guess(String gameId, Prediction prediction) => Guess(
      userId: 'uid-test',
      gameId: gameId,
      prediction: prediction,
      submittedAt: DateTime.utc(2026, 6, 10, 9, 0),
    );

ScoreSummary _calc(List<Game> games, List<Guess> guesses) => calculate(
      userId: 'uid-test',
      finishedGames: games,
      userGuesses: guesses,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('individual game scoring', () {
    // Note: these tests use two games on the same day so the set bonus never
    // fires. This isolates the +1 per game rule from the +2 set bonus rule.

    test('+1 for a correct prediction (teamAWins)', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 1); // teamBWins
      // Only guess game1 — game2 missed, so no perfect day → no set bonus.
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
    test('+2 bonus when all games on the same day are correct', () {
      final game1 = _finishedGame(id: 'g1', homeScore: 2, awayScore: 1); // teamAWins
      final game2 = _finishedGame(id: 'g2', homeScore: 0, awayScore: 0); // draw
      final guesses = [
        _guess('g1', Prediction.teamAWins),
        _guess('g2', Prediction.draw),
      ];

      final summary = _calc([game1, game2], guesses);

      expect(summary.correctGuesses, 2);
      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 4); // 2 + 2
    });

    test('no set bonus when one game on the day is wrong', () {
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

    test('no set bonus when one game on the day was missed', () {
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

    test('single game day can earn the set bonus', () {
      final game = _finishedGame(id: 'g1', homeScore: 1, awayScore: 0);
      final summary = _calc([game], [_guess('g1', Prediction.teamAWins)]);

      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 3); // 1 + 2
    });
  });

  group('multiple days', () {
    test('bonus only on perfect days — imperfect days earn no bonus', () {
      // Day 1 — June 11: two games, both correct → set bonus
      final day1game1 = _finishedGame(
        id: 'g1',
        homeScore: 1,
        awayScore: 0,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
      );
      final day1game2 = _finishedGame(
        id: 'g2',
        homeScore: 0,
        awayScore: 0,
        kickoffTime: DateTime.utc(2026, 6, 11, 19, 0),
      );
      // Day 2 — June 12: one correct, one wrong → no set bonus
      final day2game1 = _finishedGame(
        id: 'g3',
        homeScore: 3,
        awayScore: 0,
        kickoffTime: DateTime.utc(2026, 6, 12, 15, 0),
      );
      final day2game2 = _finishedGame(
        id: 'g4',
        homeScore: 1,
        awayScore: 2,
        kickoffTime: DateTime.utc(2026, 6, 12, 19, 0),
      );

      final guesses = [
        _guess('g1', Prediction.teamAWins), // ✓
        _guess('g2', Prediction.draw),      // ✓
        _guess('g3', Prediction.teamAWins), // ✓
        _guess('g4', Prediction.teamAWins), // ✗ (teamBWins)
      ];

      final summary = _calc(
        [day1game1, day1game2, day2game1, day2game2],
        guesses,
      );

      expect(summary.correctGuesses, 3);
      expect(summary.setBonusCount, 1);   // only day 1
      expect(summary.totalPoints, 5);     // 3 + 2
    });

    test('two perfect days earns two set bonuses', () {
      final day1 = _finishedGame(
        id: 'g1',
        homeScore: 1,
        awayScore: 0,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
      );
      final day2 = _finishedGame(
        id: 'g2',
        homeScore: 0,
        awayScore: 1,
        kickoffTime: DateTime.utc(2026, 6, 12, 15, 0),
      );

      final summary = _calc(
        [day1, day2],
        [
          _guess('g1', Prediction.teamAWins),
          _guess('g2', Prediction.teamBWins),
        ],
      );

      expect(summary.setBonusCount, 2);
      expect(summary.totalPoints, 6); // 2 + 4
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
        submittedAt: DateTime.utc(2026, 6, 10),
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

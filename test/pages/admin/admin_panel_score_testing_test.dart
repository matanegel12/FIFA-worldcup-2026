import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/score_summary.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/scoring/scoring_calculator.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _home = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _away = Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina');
const String _userId = 'user-1';

Game _finishedGame(
  String id,
  int home,
  int away, {
  bool isTestResult = false,
  DateTime? kickoff,
}) =>
    Game(
      id: id,
      homeTeam: _home,
      awayTeam: _away,
      kickoffTime: kickoff ?? DateTime.utc(2026, 6, 11, 15, 0),
      homeScore: home,
      awayScore: away,
      status: GameStatus.finished,
      isTestResult: isTestResult,
    );

Guess _guess(String gameId, Prediction prediction) =>
    Guess(userId: _userId, gameId: gameId, prediction: prediction);

// ── Game model — isTestResult field ──────────────────────────────────────────

void main() {
  group('Game.isTestResult', () {
    test('defaults to false', () {
      final Game g = _finishedGame('g1', 1, 0);
      expect(g.isTestResult, isFalse);
    });

    test('can be set to true', () {
      final Game g = _finishedGame('g1', 1, 0, isTestResult: true);
      expect(g.isTestResult, isTrue);
    });

    test('fromJson defaults to false when field is absent', () {
      final Game g = Game.fromJson({
        'id': 'g1',
        'homeTeam': {'fifaCode': 'MEX', 'isoCode': 'mx', 'name': 'Mexico'},
        'awayTeam': {'fifaCode': 'ARG', 'isoCode': 'ar', 'name': 'Argentina'},
        'kickoffTime': '2026-06-11T15:00:00.000Z',
        'homeScore': 1,
        'awayScore': 0,
        'status': 'finished',
      });
      expect(g.isTestResult, isFalse);
    });

    test('fromJson reads isTestResult = true', () {
      final Game g = Game.fromJson({
        'id': 'g1',
        'homeTeam': {'fifaCode': 'MEX', 'isoCode': 'mx', 'name': 'Mexico'},
        'awayTeam': {'fifaCode': 'ARG', 'isoCode': 'ar', 'name': 'Argentina'},
        'kickoffTime': '2026-06-11T15:00:00.000Z',
        'homeScore': 2,
        'awayScore': 1,
        'status': 'finished',
        'isTestResult': true,
      });
      expect(g.isTestResult, isTrue);
    });

    test('toJson includes isTestResult', () {
      final Game g = _finishedGame('g1', 1, 0, isTestResult: true);
      expect(g.toJson()['isTestResult'], isTrue);
    });

    test('toJson includes isTestResult = false for normal game', () {
      final Game g = _finishedGame('g1', 1, 0);
      expect(g.toJson()['isTestResult'], isFalse);
    });
  });

  // ── forceGameResult — scoring logic ──────────────────────────────────────

  group('forceGameResult — scoring (via calculate)', () {
    test('correct prediction earns +1', () {
      // Two games on the same day — one guessed correctly, one not guessed.
      // Not a perfect day → no set bonus → exactly +1.
      final List<Game> finished = [
        _finishedGame('g1', 2, 1, isTestResult: true),
        _finishedGame('g2', 1, 0, isTestResult: true), // no guess — breaks perfect day
      ];
      final List<Guess> guesses = [_guess('g1', Prediction.teamAWins)];

      final ScoreSummary summary =
          calculate(userId: _userId, finishedGames: finished, userGuesses: guesses);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('wrong prediction earns 0', () {
      // Mexico 0-1 Argentina → outcome = teamBWins, user guessed teamAWins
      final List<Game> finished = [_finishedGame('g1', 0, 1, isTestResult: true)];
      final List<Guess> guesses = [_guess('g1', Prediction.teamAWins)];

      final ScoreSummary summary =
          calculate(userId: _userId, finishedGames: finished, userGuesses: guesses);

      expect(summary.correctGuesses, 0);
      expect(summary.totalPoints, 0);
    });

    test('set bonus (+2) triggers when all games on same day are correct', () {
      final DateTime sameDay = DateTime.utc(2026, 6, 15);

      final List<Game> finished = [
        _finishedGame('g1', 2, 1, isTestResult: true, kickoff: sameDay),
        _finishedGame('g2', 0, 0, isTestResult: true,
            kickoff: sameDay.add(const Duration(hours: 3))),
      ];

      final List<Guess> guesses = [
        _guess('g1', Prediction.teamAWins), // correct
        _guess('g2', Prediction.draw),       // correct
      ];

      final ScoreSummary summary =
          calculate(userId: _userId, finishedGames: finished, userGuesses: guesses);

      expect(summary.correctGuesses, 2);
      expect(summary.setBonusCount, 1);
      expect(summary.totalPoints, 4); // 2 correct + 2 set bonus
    });

    test('set bonus does NOT trigger if one game on the day is wrong', () {
      final DateTime sameDay = DateTime.utc(2026, 6, 15);

      final List<Game> finished = [
        _finishedGame('g1', 2, 1, isTestResult: true, kickoff: sameDay),
        _finishedGame('g2', 0, 0, isTestResult: true,
            kickoff: sameDay.add(const Duration(hours: 3))),
      ];

      final List<Guess> guesses = [
        _guess('g1', Prediction.teamAWins), // correct
        _guess('g2', Prediction.teamAWins), // wrong (was draw)
      ];

      final ScoreSummary summary =
          calculate(userId: _userId, finishedGames: finished, userGuesses: guesses);

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });
  });

  // ── clearTestResults — filtering ──────────────────────────────────────────

  group('clearTestResults — isTestResult filtering', () {
    test('test games are identified by isTestResult == true', () {
      final List<Game> allGames = [
        _finishedGame('g1', 2, 1),                     // real
        _finishedGame('g2', 1, 1, isTestResult: true), // test
        _finishedGame('g3', 0, 3, isTestResult: true), // test
      ];

      final List<Game> testGames =
          allGames.where((Game g) => g.isTestResult).toList();

      expect(testGames.length, 2);
      expect(testGames.map((Game g) => g.id), containsAll(['g2', 'g3']));
    });

    test('no test games remain after filtering out isTestResult == true', () {
      final List<Game> allGames = [
        _finishedGame('g1', 2, 1),
        _finishedGame('g2', 1, 1, isTestResult: true),
      ];

      final List<Game> remaining =
          allGames.where((Game g) => !g.isTestResult).toList();

      expect(remaining.every((Game g) => !g.isTestResult), isTrue);
      expect(remaining.length, 1);
      expect(remaining.first.id, 'g1');
    });
  });

  // ── recomputeAllScores — test games excluded from scoring ─────────────────

  group('recomputeAllScores — test game exclusion', () {
    test('test game scores are excluded from recomputed totals', () {
      // Two real games + one test game. User guesses real correctly, test correctly.
      // After filtering, only real games count. A companion real game with no guess
      // prevents the perfect-day set bonus.
      final List<Game> allFinished = [
        _finishedGame('real1', 2, 1),                    // real — user guesses correctly
        _finishedGame('real2', 1, 0),                    // real — no guess (breaks perfect day)
        _finishedGame('test', 1, 0, isTestResult: true), // test — excluded
      ];

      final List<Game> realOnly =
          allFinished.where((Game g) => !g.isTestResult).toList();

      final List<Guess> guesses = [
        _guess('real1', Prediction.teamAWins), // correct
        _guess('test', Prediction.teamAWins),  // excluded
      ];

      final ScoreSummary summary = calculate(
        userId: _userId,
        finishedGames: realOnly,
        userGuesses: guesses,
      );

      expect(summary.correctGuesses, 1);
      expect(summary.setBonusCount, 0);
      expect(summary.totalPoints, 1);
    });

    test('leaderboard order is correct after recompute', () {
      // Two real games on the SAME day. user-a gets both correct (set bonus).
      // user-b gets only one correct (no set bonus).
      final DateTime day = DateTime.utc(2026, 6, 15);
      final List<Game> realGames = [
        _finishedGame('g1', 2, 1, kickoff: day),
        _finishedGame('g2', 0, 1, kickoff: day.add(const Duration(hours: 3))),
      ];

      // Guesses must carry the correct userId to be counted
      final ScoreSummary summaryA = calculate(
        userId: 'user-a',
        finishedGames: realGames,
        userGuesses: [
          Guess(userId: 'user-a', gameId: 'g1', prediction: Prediction.teamAWins), // correct
          Guess(userId: 'user-a', gameId: 'g2', prediction: Prediction.teamBWins), // correct
        ],
      );

      final ScoreSummary summaryB = calculate(
        userId: 'user-b',
        finishedGames: realGames,
        userGuesses: [
          Guess(userId: 'user-b', gameId: 'g1', prediction: Prediction.teamBWins), // wrong
          Guess(userId: 'user-b', gameId: 'g2', prediction: Prediction.teamBWins), // correct
        ],
      );

      // user-a: 2 correct + 1 set bonus = 4 pts
      // user-b: 1 correct + 0 set bonus = 1 pt
      expect(summaryA.totalPoints, 4);
      expect(summaryB.totalPoints, 1);
      expect(summaryA.totalPoints, greaterThan(summaryB.totalPoints));
    });
  });
}

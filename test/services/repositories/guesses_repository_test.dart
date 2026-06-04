import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';

void main() {
  late MockGuessesRepository repo;

  final t = DateTime.utc(2026, 6, 10, 9, 0);

  final guessUser1Game1 = Guess(
    userId: 'uid-1',
    gameId: 'g1',
    prediction: Prediction.teamAWins,
    submittedAt: t,
  );
  final guessUser1Game2 = Guess(
    userId: 'uid-1',
    gameId: 'g2',
    prediction: Prediction.draw,
    submittedAt: t,
  );
  final guessUser2Game1 = Guess(
    userId: 'uid-2',
    gameId: 'g1',
    prediction: Prediction.teamBWins,
    submittedAt: t,
  );

  setUp(() {
    MockStore.instance.resetAll();
    repo = MockGuessesRepository();
  });

  group('fetchGuess', () {
    test('returns null when no guess exists', () async {
      expect(await repo.fetchGuess('uid-1', 'g1'), isNull);
    });

    test('returns the correct guess', () async {
      await repo.saveGuess(guessUser1Game1);

      final result = await repo.fetchGuess('uid-1', 'g1');
      expect(result?.prediction, Prediction.teamAWins);
    });
  });

  group('fetchGuessesForUser', () {
    test('returns empty when user has no guesses', () async {
      expect(await repo.fetchGuessesForUser('uid-1'), isEmpty);
    });

    test('returns only that user\'s guesses', () async {
      await repo.saveGuess(guessUser1Game1);
      await repo.saveGuess(guessUser1Game2);
      await repo.saveGuess(guessUser2Game1);

      final result = await repo.fetchGuessesForUser('uid-1');
      expect(result.length, 2);
      expect(result.every((g) => g.userId == 'uid-1'), isTrue);
    });
  });

  group('fetchGuessesForGame', () {
    test('returns empty when no guesses exist for the game', () async {
      expect(await repo.fetchGuessesForGame('g1'), isEmpty);
    });

    test('returns all users\' guesses for a game', () async {
      await repo.saveGuess(guessUser1Game1);
      await repo.saveGuess(guessUser2Game1);
      await repo.saveGuess(guessUser1Game2); // different game — should not appear

      final result = await repo.fetchGuessesForGame('g1');
      expect(result.length, 2);
      expect(result.every((g) => g.gameId == 'g1'), isTrue);
    });
  });

  group('saveGuess', () {
    test('saves a new guess', () async {
      await repo.saveGuess(guessUser1Game1);

      final result = await repo.fetchGuess('uid-1', 'g1');
      expect(result, isNotNull);
      expect(result!.prediction, Prediction.teamAWins);
    });

    test('overwriting a guess updates prediction AND submittedAt', () async {
      await repo.saveGuess(guessUser1Game1); // saved at 09:00

      final updated = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.draw,
        submittedAt: DateTime.utc(2026, 6, 10, 15, 0), // changed at 15:00
      );
      await repo.saveGuess(updated);

      final result = await repo.fetchGuess('uid-1', 'g1');
      expect(result!.prediction, Prediction.draw);
      expect(result.submittedAt, DateTime.utc(2026, 6, 10, 15, 0));
    });

    test('only one guess exists per user per game after multiple saves', () async {
      await repo.saveGuess(guessUser1Game1);
      await repo.saveGuess(Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamBWins,
        submittedAt: DateTime.utc(2026, 6, 10, 12, 0),
      ));

      final all = await repo.fetchGuessesForGame('g1');
      expect(all.length, 1); // no duplicates
    });
  });
}

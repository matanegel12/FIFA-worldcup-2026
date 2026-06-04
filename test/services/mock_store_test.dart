import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/models/user.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';

void main() {
  // Always reset the singleton between tests so they don't bleed into each other.
  setUp(() => MockStore.instance.resetAll());

  const mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
  const brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

  final game1 = Game(
    id: 'g1',
    homeTeam: mexico,
    awayTeam: brazil,
    kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
    status: GameStatus.upcoming,
  );
  final game2 = Game(
    id: 'g2',
    homeTeam: brazil,
    awayTeam: mexico,
    kickoffTime: DateTime.utc(2026, 6, 12, 15, 0),
    status: GameStatus.upcoming,
  );

  final user1 = User(
    id: 'uid-1',
    email: 'a@a.com',
    displayName: 'Alice',
    totalPoints: 0,
  );

  group('MockStore — games', () {
    test('seedGames stores games', () {
      MockStore.instance.seedGames([game1, game2]);
      expect(MockStore.instance.games.length, 2);
    });

    test('upcomingGames filters correctly', () {
      MockStore.instance.seedGames([game1, game2]);
      expect(MockStore.instance.upcomingGames.length, 2);
    });

    test('setGameResult marks game as finished with scores', () {
      MockStore.instance.seedGames([game1]);
      MockStore.instance.setGameResult(
        gameId: 'g1',
        homeScore: 2,
        awayScore: 1,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );

      final updated = MockStore.instance.finishedGames.first;
      expect(updated.homeScore, 2);
      expect(updated.awayScore, 1);
      expect(updated.isFinished, isTrue);
      expect(updated.outcome, Prediction.teamAWins);
    });

    test('finishedGames filters correctly after result injection', () {
      MockStore.instance.seedGames([game1, game2]);
      MockStore.instance.setGameResult(
        gameId: 'g1',
        homeScore: 1,
        awayScore: 1,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );

      expect(MockStore.instance.finishedGames.length, 1);
      expect(MockStore.instance.upcomingGames.length, 1);
    });
  });

  group('MockStore — guesses', () {
    test('saveGuess and getGuess round-trip', () {
      final guess = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10, 9, 0),
      );
      MockStore.instance.saveGuess(guess);

      final retrieved = MockStore.instance.getGuess('uid-1', 'g1');
      expect(retrieved?.prediction, Prediction.teamAWins);
    });

    test('saving a new prediction overwrites the old one', () {
      final original = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10, 9, 0),
      );
      // New Guess with updated prediction and fresh submittedAt — no copyWith.
      final updated = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.draw,
        submittedAt: DateTime.utc(2026, 6, 10, 15, 0),
      );

      MockStore.instance.saveGuess(original);
      MockStore.instance.saveGuess(updated);

      expect(MockStore.instance.getGuess('uid-1', 'g1')?.prediction, Prediction.draw);
      expect(MockStore.instance.allGuesses.length, 1);
    });

    test('guessesForUser returns only that user\'s guesses', () {
      MockStore.instance.saveGuess(Guess(userId: 'uid-1', gameId: 'g1', prediction: Prediction.draw, submittedAt: DateTime.utc(2026, 6, 10)));
      MockStore.instance.saveGuess(Guess(userId: 'uid-2', gameId: 'g1', prediction: Prediction.teamBWins, submittedAt: DateTime.utc(2026, 6, 10)));

      expect(MockStore.instance.guessesForUser('uid-1').length, 1);
      expect(MockStore.instance.guessesForUser('uid-2').length, 1);
    });
  });

  group('MockStore — users', () {
    test('saveUser adds a new user', () {
      MockStore.instance.saveUser(user1);
      expect(MockStore.instance.users.length, 1);
    });

    test('saveUser updates an existing user', () {
      MockStore.instance.saveUser(user1);
      final updated = user1.copyWith(totalPoints: 10);
      MockStore.instance.saveUser(updated);

      expect(MockStore.instance.users.length, 1);
      expect(MockStore.instance.getUser('uid-1')?.totalPoints, 10);
    });

    test('getUser returns null for unknown id', () {
      expect(MockStore.instance.getUser('unknown'), isNull);
    });
  });

  group('MockStore — reset operations', () {
    setUp(() {
      MockStore.instance.seedGames([game1, game2]);
      MockStore.instance.seedUsers([user1]);
      MockStore.instance.saveGuess(Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10),
      ));
      MockStore.instance.setGameResult(
        gameId: 'g1',
        homeScore: 2,
        awayScore: 0,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
    });

    test('resetAll clears all games, guesses and users', () {
      MockStore.instance.resetAll();

      expect(MockStore.instance.games, isEmpty);
      expect(MockStore.instance.allGuesses, isEmpty);
      expect(MockStore.instance.users, isEmpty);
    });

    test('resetGuesses clears only guesses', () {
      MockStore.instance.resetGuesses();

      expect(MockStore.instance.allGuesses, isEmpty);
      expect(MockStore.instance.finishedGames.length, 1); // game result untouched
    });

    test('resetDay resets only games and guesses on that day', () {
      MockStore.instance.resetDay(DateTime.utc(2026, 6, 11));

      expect(MockStore.instance.finishedGames, isEmpty);
      expect(MockStore.instance.allGuesses, isEmpty);
      expect(MockStore.instance.upcomingGames.length, 2); // both back to upcoming
    });

    test('resetUsers clears users and their guesses', () {
      MockStore.instance.resetUsers();

      expect(MockStore.instance.users, isEmpty);
      expect(MockStore.instance.allGuesses, isEmpty);
      expect(MockStore.instance.games.length, 2); // games untouched
    });
  });
}

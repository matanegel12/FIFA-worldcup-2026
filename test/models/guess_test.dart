import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';

void main() {
  const guess = Guess(
    userId: 'uid-abc',
    gameId: 'g1',
    prediction: Prediction.teamAWins,
  );

  group('Guess.fromJson', () {
    test('creates guess with correct fields', () {
      final result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'teamAWins',
      });

      expect(result.userId, 'uid-abc');
      expect(result.gameId, 'g1');
      expect(result.prediction, Prediction.teamAWins);
    });

    test('parses all three prediction values', () {
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamAWins'}).prediction,
        Prediction.teamAWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamBWins'}).prediction,
        Prediction.teamBWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'draw'}).prediction,
        Prediction.draw,
      );
    });
  });

  group('Guess.toJson', () {
    test('serializes all fields correctly', () {
      final json = guess.toJson();

      expect(json['userId'], 'uid-abc');
      expect(json['gameId'], 'g1');
      expect(json['prediction'], 'teamAWins');
    });
  });

  group('round-trip', () {
    test('fromJson(toJson()) returns equal guess', () {
      final restored = Guess.fromJson(guess.toJson());
      expect(restored, guess);
    });
  });

  group('compoundId', () {
    test('builds userId_gameId format', () {
      expect(Guess.compoundId('uid-abc', 'g1'), 'uid-abc_g1');
    });

    test('different users produce different compound IDs', () {
      expect(
        Guess.compoundId('uid-abc', 'g1'),
        isNot(equals(Guess.compoundId('uid-xyz', 'g1'))),
      );
    });

    test('different games produce different compound IDs', () {
      expect(
        Guess.compoundId('uid-abc', 'g1'),
        isNot(equals(Guess.compoundId('uid-abc', 'g2'))),
      );
    });
  });

  group('equality', () {
    test('same userId and gameId are equal regardless of prediction', () {
      const other = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamBWins,
      );
      expect(guess, equals(other));
    });

    test('different userId are not equal', () {
      const other = Guess(
        userId: 'uid-xyz',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
      );
      expect(guess, isNot(equals(other)));
    });

    test('different gameId are not equal', () {
      const other = Guess(
        userId: 'uid-abc',
        gameId: 'g2',
        prediction: Prediction.teamAWins,
      );
      expect(guess, isNot(equals(other)));
    });
  });
}

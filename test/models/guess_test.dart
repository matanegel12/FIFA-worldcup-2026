import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';

void main() {
  final submittedAt = DateTime.utc(2026, 6, 10, 9, 0);

  final guess = Guess(
    userId: 'uid-abc',
    gameId: 'g1',
    prediction: Prediction.teamAWins,
    submittedAt: submittedAt,
  );

  group('Guess.fromJson', () {
    test('creates guess with correct fields', () {
      final result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'teamAWins',
        'submittedAt': '2026-06-10T09:00:00.000Z',
      });

      expect(result.userId, 'uid-abc');
      expect(result.gameId, 'g1');
      expect(result.prediction, Prediction.teamAWins);
      expect(result.submittedAt, DateTime.utc(2026, 6, 10, 9, 0));
    });

    test('parses submittedAt as UTC', () {
      final result = Guess.fromJson({
        'userId': 'u',
        'gameId': 'g',
        'prediction': 'draw',
        'submittedAt': '2026-06-10T09:00:00.000Z',
      });

      expect(result.submittedAt.isUtc, isTrue);
    });

    test('parses all three prediction values', () {
      final t = DateTime.utc(2026, 6, 10).toIso8601String();
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamAWins', 'submittedAt': t}).prediction,
        Prediction.teamAWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamBWins', 'submittedAt': t}).prediction,
        Prediction.teamBWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'draw', 'submittedAt': t}).prediction,
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
      expect(json['submittedAt'], '2026-06-10T09:00:00.000Z');
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

  group('submittedAt updates on every save', () {
    test('changing prediction creates a new Guess with a later submittedAt', () {
      final original = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10, 12, 0), // guessed at 12:00
      );
      final updated = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.draw,
        submittedAt: DateTime.utc(2026, 6, 10, 15, 0), // changed at 15:00
      );

      expect(updated.prediction, Prediction.draw);
      expect(updated.submittedAt.isAfter(original.submittedAt), isTrue);
    });

    test('later submittedAt loses the tiebreaker', () {
      final early = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10, 8, 0),
      );
      final late = Guess(
        userId: 'uid-2',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: DateTime.utc(2026, 6, 10, 15, 0),
      );

      expect(early.submittedAt.isBefore(late.submittedAt), isTrue);
    });
  });

  group('equality', () {
    test('same userId and gameId are equal regardless of prediction', () {
      final other = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamBWins,
        submittedAt: submittedAt,
      );
      expect(guess, equals(other));
    });

    test('different userId are not equal', () {
      final other = Guess(
        userId: 'uid-xyz',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        submittedAt: submittedAt,
      );
      expect(guess, isNot(equals(other)));
    });

    test('different gameId are not equal', () {
      final other = Guess(
        userId: 'uid-abc',
        gameId: 'g2',
        prediction: Prediction.teamAWins,
        submittedAt: submittedAt,
      );
      expect(guess, isNot(equals(other)));
    });
  });
}

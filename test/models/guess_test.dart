import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';

void main() {
  final createdAt = DateTime.utc(2026, 6, 10, 9, 0);

  final guess = Guess(
    userId: 'uid-abc',
    gameId: 'g1',
    prediction: Prediction.teamAWins,
    createdAt: createdAt,
  );

  group('Guess.fromJson', () {
    test('creates guess with correct fields', () {
      final result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'teamAWins',
        'createdAt': '2026-06-10T09:00:00.000Z',
      });

      expect(result.userId, 'uid-abc');
      expect(result.gameId, 'g1');
      expect(result.prediction, Prediction.teamAWins);
      expect(result.createdAt, DateTime.utc(2026, 6, 10, 9, 0));
    });

    test('parses createdAt as UTC', () {
      final result = Guess.fromJson({
        'userId': 'u',
        'gameId': 'g',
        'prediction': 'draw',
        'createdAt': '2026-06-10T09:00:00.000Z',
      });

      expect(result.createdAt.isUtc, isTrue);
    });

    test('parses all three prediction values', () {
      DateTime t = DateTime.utc(2026, 6, 10);
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamAWins', 'createdAt': t.toIso8601String()}).prediction,
        Prediction.teamAWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'teamBWins', 'createdAt': t.toIso8601String()}).prediction,
        Prediction.teamBWins,
      );
      expect(
        Guess.fromJson({'userId': 'u', 'gameId': 'g', 'prediction': 'draw', 'createdAt': t.toIso8601String()}).prediction,
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
      expect(json['createdAt'], '2026-06-10T09:00:00.000Z');
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

  group('copyWith', () {
    test('updates prediction without changing other fields', () {
      final updated = guess.copyWith(prediction: Prediction.draw);

      expect(updated.prediction, Prediction.draw);
      expect(updated.userId, guess.userId);
      expect(updated.gameId, guess.gameId);
      expect(updated.createdAt, guess.createdAt);
    });

    test('createdAt is preserved — it is set once and never changed', () {
      final updated = guess.copyWith(prediction: Prediction.teamBWins);
      expect(updated.createdAt, guess.createdAt);
    });
  });

  group('equality', () {
    test('same userId and gameId are equal regardless of prediction', () {
      final updated = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamBWins,
        createdAt: createdAt,
      );
      expect(guess, equals(updated));
    });

    test('different userId are not equal', () {
      final other = Guess(
        userId: 'uid-xyz',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        createdAt: createdAt,
      );
      expect(guess, isNot(equals(other)));
    });

    test('different gameId are not equal', () {
      final other = Guess(
        userId: 'uid-abc',
        gameId: 'g2',
        prediction: Prediction.teamAWins,
        createdAt: createdAt,
      );
      expect(guess, isNot(equals(other)));
    });
  });

  group('secondary tiebreaker', () {
    test('earlier createdAt sorts before later createdAt', () {
      final early = Guess(
        userId: 'uid-1',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        createdAt: DateTime.utc(2026, 6, 10, 8, 0),
      );
      final late = Guess(
        userId: 'uid-2',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        createdAt: DateTime.utc(2026, 6, 10, 10, 0),
      );

      expect(early.createdAt.isBefore(late.createdAt), isTrue);
    });
  });
}

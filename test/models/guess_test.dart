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

  group('predictedHomeScore / predictedAwayScore', () {
    test('fromJson parses non-null score predictions', () {
      final Guess result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'teamAWins',
        'predictedHomeScore': 2,
        'predictedAwayScore': 1,
      });
      expect(result.predictedHomeScore, 2);
      expect(result.predictedAwayScore, 1);
    });

    test('fromJson parses null score predictions', () {
      final Guess result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'draw',
        'predictedHomeScore': null,
        'predictedAwayScore': null,
      });
      expect(result.predictedHomeScore, isNull);
      expect(result.predictedAwayScore, isNull);
    });

    test('fromJson defaults scores to null when fields are absent', () {
      final Guess result = Guess.fromJson({
        'userId': 'uid-abc',
        'gameId': 'g1',
        'prediction': 'draw',
      });
      expect(result.predictedHomeScore, isNull);
      expect(result.predictedAwayScore, isNull);
    });

    test('toJson includes non-null score predictions', () {
      const Guess withScores = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamAWins,
        predictedHomeScore: 3,
        predictedAwayScore: 0,
      );
      final Map<String, dynamic> json = withScores.toJson();
      expect(json['predictedHomeScore'], 3);
      expect(json['predictedAwayScore'], 0);
    });

    test('toJson serializes null scores as null', () {
      final Map<String, dynamic> json = guess.toJson();
      expect(json['predictedHomeScore'], isNull);
      expect(json['predictedAwayScore'], isNull);
    });

    test('round-trip preserves non-null scores', () {
      const Guess withScores = Guess(
        userId: 'uid-abc',
        gameId: 'g1',
        prediction: Prediction.teamBWins,
        predictedHomeScore: 1,
        predictedAwayScore: 2,
      );
      final Guess restored = Guess.fromJson(withScores.toJson());
      expect(restored.predictedHomeScore, 1);
      expect(restored.predictedAwayScore, 2);
    });

    test('defaults to null when not provided in constructor', () {
      expect(guess.predictedHomeScore, isNull);
      expect(guess.predictedAwayScore, isNull);
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

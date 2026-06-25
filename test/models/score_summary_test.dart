import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/score_summary.dart';

void main() {
  group('ScoreSummary.totalPoints', () {
    test('correct guesses only — no set bonus', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 3,
        setBonusCount: 0,
      );
      expect(summary.totalPoints, 3);
    });

    test('set bonus only — no individual correct guesses', () {
      // Not a realistic case, but the formula should still hold
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        setBonusCount: 2,
      );
      expect(summary.totalPoints, 4); // 2 × 2
    });

    test('correct guesses + set bonuses combined', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 4,
        setBonusCount: 1,
      );
      expect(summary.totalPoints, 6); // 4 + (1 × 2)
    });

    test('knockout correct guesses are worth 2 each', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        knockoutCorrectGuesses: 3,
        setBonusCount: 0,
      );
      expect(summary.totalPoints, 6); // 3 × 2
    });

    test('group, knockout and set bonus points all add up', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 2, // +2
        knockoutCorrectGuesses: 2, // +4
        setBonusCount: 1, // +2
      );
      expect(summary.totalPoints, 8);
    });

    test('zero everything gives zero points', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        setBonusCount: 0,
      );
      expect(summary.totalPoints, 0);
    });

    test('set bonus is worth exactly 2 points per set', () {
      const oneBonus = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        setBonusCount: 1,
      );
      const twoBonus = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        setBonusCount: 2,
      );
      expect(twoBonus.totalPoints - oneBonus.totalPoints, 2);
    });
  });

  group('equality', () {
    test('same fields are equal', () {
      const a = ScoreSummary(userId: 'uid-1', correctGuesses: 3, setBonusCount: 1);
      const b = ScoreSummary(userId: 'uid-1', correctGuesses: 3, setBonusCount: 1);
      expect(a, equals(b));
    });

    test('different correctGuesses are not equal', () {
      const a = ScoreSummary(userId: 'uid-1', correctGuesses: 3, setBonusCount: 1);
      const b = ScoreSummary(userId: 'uid-1', correctGuesses: 4, setBonusCount: 1);
      expect(a, isNot(equals(b)));
    });

    test('different setBonusCount are not equal', () {
      const a = ScoreSummary(userId: 'uid-1', correctGuesses: 3, setBonusCount: 1);
      const b = ScoreSummary(userId: 'uid-1', correctGuesses: 3, setBonusCount: 0);
      expect(a, isNot(equals(b)));
    });

    test('different knockoutCorrectGuesses are not equal', () {
      const a = ScoreSummary(
          userId: 'uid-1',
          correctGuesses: 3,
          knockoutCorrectGuesses: 1,
          setBonusCount: 1);
      const b = ScoreSummary(
          userId: 'uid-1',
          correctGuesses: 3,
          knockoutCorrectGuesses: 2,
          setBonusCount: 1);
      expect(a, isNot(equals(b)));
    });
  });
}

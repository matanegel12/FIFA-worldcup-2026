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

    test('knockoutPoints is added as-is — already weighted by round', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 0,
        knockoutPoints: 6, // e.g. 2 correct Round of 16 guesses at 3 each
        setBonusCount: 0,
      );
      expect(summary.totalPoints, 6);
    });

    test('group, knockout and set bonus points all add up', () {
      const summary = ScoreSummary(
        userId: 'uid-1',
        correctGuesses: 2, // +2
        knockoutPoints: 4, // e.g. 2 correct Round of 32 guesses at 2 each
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

    test('different knockoutPoints are not equal', () {
      const a = ScoreSummary(
          userId: 'uid-1', correctGuesses: 3, knockoutPoints: 2, setBonusCount: 1);
      const b = ScoreSummary(
          userId: 'uid-1', correctGuesses: 3, knockoutPoints: 4, setBonusCount: 1);
      expect(a, isNot(equals(b)));
    });
  });
}

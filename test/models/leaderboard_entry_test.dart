import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/leaderboard_entry.dart';

void main() {
  const first = LeaderboardEntry(
    rank: 1,
    userId: 'uid-abc',
    displayName: 'Alice',
    totalPoints: 20,
  );

  const tenth = LeaderboardEntry(
    rank: 10,
    userId: 'uid-xyz',
    displayName: 'Zara',
    totalPoints: 5,
  );

  group('LeaderboardEntry', () {
    test('maxSize is 10', () {
      expect(LeaderboardEntry.maxSize, 10);
    });

    test('holds correct fields', () {
      expect(first.rank, 1);
      expect(first.userId, 'uid-abc');
      expect(first.displayName, 'Alice');
      expect(first.totalPoints, 20);
    });

    test('rank 10 is valid (within maxSize)', () {
      expect(tenth.rank <= LeaderboardEntry.maxSize, isTrue);
    });
  });

  group('equality', () {
    test('same userId are equal regardless of rank or points', () {
      const sameUser = LeaderboardEntry(
        rank: 3,
        userId: 'uid-abc',
        displayName: 'Alice',
        totalPoints: 99,
      );
      expect(first, equals(sameUser));
    });

    test('different userId are not equal', () {
      expect(first, isNot(equals(tenth)));
    });
  });

  group('sorting simulation', () {
    test('higher points rank first', () {
      final entries = [tenth, first];
      entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      expect(entries.first.userId, 'uid-abc');
    });

    test('top 10 list never exceeds maxSize', () {
      final allEntries = List.generate(
        15,
        (i) => LeaderboardEntry(
          rank: i + 1,
          userId: 'uid-$i',
          displayName: 'Player $i',
          totalPoints: 20 - i,
        ),
      );

      final top10 = allEntries.take(LeaderboardEntry.maxSize).toList();
      expect(top10.length, LeaderboardEntry.maxSize);
    });
  });
}

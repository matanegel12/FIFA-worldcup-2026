import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/leaderboard_entry.dart';
import 'package:fifa_worldcup_2026_predictions/models/user.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/leaderboard_sorter.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

User _user(String id, int points, {DateTime? scoreReachedAt}) => User(
      id: id,
      email: '$id@test.com',
      displayName: id,
      totalPoints: points,
      scoreReachedAt: scoreReachedAt,
    );

// ── Sorting logic (pure, no MockStore needed) ─────────────────────────────────

void main() {
  group('buildRankedEntries — sorting', () {
    test('sorts by points descending', () {
      final users = [
        _user('c', 5),
        _user('a', 20),
        _user('b', 10),
      ];
      final entries = buildRankedEntries(users);

      expect(entries[0].userId, 'a'); // 20 pts
      expect(entries[1].userId, 'b'); // 10 pts
      expect(entries[2].userId, 'c'); // 5 pts
    });

    test('assigns ranks starting at 1', () {
      final users = [_user('a', 20), _user('b', 10), _user('c', 5)];
      final entries = buildRankedEntries(users);

      expect(entries[0].rank, 1);
      expect(entries[1].rank, 2);
      expect(entries[2].rank, 3);
    });

    test('tiebreaker: earlier scoreReachedAt wins', () {
      final users = [
        _user('late', 10, scoreReachedAt: DateTime.utc(2026, 6, 11, 19, 0)),
        _user('early', 10, scoreReachedAt: DateTime.utc(2026, 6, 11, 17, 0)),
      ];
      final entries = buildRankedEntries(users);

      expect(entries[0].userId, 'early');
      expect(entries[1].userId, 'late');
    });

    test('tiebreaker: null scoreReachedAt goes last', () {
      final users = [
        _user('unscored', 5),
        _user('scored', 5,
            scoreReachedAt: DateTime.utc(2026, 6, 11, 17, 0)),
      ];
      final entries = buildRankedEntries(users);

      expect(entries[0].userId, 'scored');
      expect(entries[1].userId, 'unscored');
    });

    test('tiebreaker: userId alphabetical as final fallback', () {
      final sameTime = DateTime.utc(2026, 6, 11, 17, 0);
      final users = [
        _user('zzz', 10, scoreReachedAt: sameTime),
        _user('aaa', 10, scoreReachedAt: sameTime),
      ];
      final entries = buildRankedEntries(users);

      expect(entries[0].userId, 'aaa');
      expect(entries[1].userId, 'zzz');
    });

    test('returns empty list for empty input', () {
      expect(buildRankedEntries([]), isEmpty);
    });
  });

  // ── Repository (full flow through MockStore) ──────────────────────────────

  group('MockLeaderboardRepository', () {
    late MockLeaderboardRepository repo;

    setUp(() {
      MockStore.instance.resetAll();
      repo = MockLeaderboardRepository();
    });

    test('fetchTop10 returns empty when no users', () async {
      expect(await repo.fetchTop10(), isEmpty);
    });

    test('fetchTop10 returns at most 10 entries', () async {
      final users = List.generate(
        15,
        (i) => _user('uid-$i', 20 - i,
            scoreReachedAt: DateTime.utc(2026, 6, 11, i, 0)),
      );
      MockStore.instance.seedUsers(users);

      final top10 = await repo.fetchTop10();
      expect(top10.length, LeaderboardEntry.maxSize);
    });

    test('fetchTop10 returns fewer than 10 when not enough users', () async {
      MockStore.instance.seedUsers([_user('uid-1', 5), _user('uid-2', 3)]);

      final top10 = await repo.fetchTop10();
      expect(top10.length, 2);
    });

    test('fetchTop10 is sorted correctly', () async {
      MockStore.instance.seedUsers([
        _user('uid-b', 5),
        _user('uid-a', 10),
      ]);

      final top10 = await repo.fetchTop10();
      expect(top10[0].userId, 'uid-a');
      expect(top10[1].userId, 'uid-b');
    });

    test('fetchUserEntry returns correct rank for top-10 user', () async {
      MockStore.instance.seedUsers([
        _user('uid-1', 20),
        _user('uid-2', 15),
        _user('uid-3', 10),
      ]);

      final entry = await repo.fetchUserEntry('uid-2');
      expect(entry?.rank, 2);
      expect(entry?.totalPoints, 15);
    });

    test('fetchUserEntry returns correct rank for user outside top 10', () async {
      final users = List.generate(
        12,
        (i) => _user('uid-$i', 100 - (i * 5),
            scoreReachedAt: DateTime.utc(2026, 6, 11, i, 0)),
      );
      MockStore.instance.seedUsers(users);

      // uid-11 has the lowest points and is ranked 12th
      final entry = await repo.fetchUserEntry('uid-11');
      expect(entry?.rank, 12);
    });

    test('fetchUserEntry returns null for unknown user', () async {
      expect(await repo.fetchUserEntry('nobody'), isNull);
    });
  });
}

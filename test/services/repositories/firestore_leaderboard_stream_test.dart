import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fifa_worldcup_2026_predictions/models/leaderboard_entry.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/firestore_leaderboard_repository.dart';

Future<void> _seedUser(
  FakeFirebaseFirestore db,
  String id,
  int points, {
  String? scoreReachedAt,
}) =>
    db.collection('users').doc(id).set({
      'email': '$id@example.com',
      'displayName': id.toUpperCase(),
      'totalPoints': points,
      'scoreReachedAt': scoreReachedAt,
    });

void main() {
  group('FirestoreLeaderboardRepository.watchRankedEntries', () {
    test('emits the current ranking immediately', () async {
      final db = FakeFirebaseFirestore();
      await _seedUser(db, 'a', 10);
      await _seedUser(db, 'b', 5);
      final repo = FirestoreLeaderboardRepository(firestore: db);

      final List<LeaderboardEntry> first =
          await repo.watchRankedEntries().first;

      expect(first.map((e) => e.userId), ['a', 'b']);
      expect(first.first.rank, 1);
      expect(first.first.totalPoints, 10);
    });

    test('emits a NEW ranking when a user score changes (live update)',
        () async {
      final db = FakeFirebaseFirestore();
      await _seedUser(db, 'a', 10);
      await _seedUser(db, 'b', 5);
      final repo = FirestoreLeaderboardRepository(firestore: db);

      // Collect the first two emissions: the initial ranking, then the one
      // produced after b overtakes a.
      final Future<List<List<LeaderboardEntry>>> twoEmissions =
          repo.watchRankedEntries().take(2).toList();

      // Let the initial snapshot fire, then change b's score.
      await Future<void>.delayed(Duration.zero);
      await db.collection('users').doc('b').update({'totalPoints': 20});

      final List<List<LeaderboardEntry>> emissions = await twoEmissions;

      // First emission: a leads.
      expect(emissions.first.map((e) => e.userId), ['a', 'b']);
      // Second emission (after the change): b now leads — the stream updated
      // itself with no re-fetch.
      expect(emissions.last.map((e) => e.userId), ['b', 'a']);
      expect(emissions.last.first.totalPoints, 20);
    });
  });
}

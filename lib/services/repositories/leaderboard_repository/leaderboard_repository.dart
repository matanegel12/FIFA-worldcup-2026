import '../../../models/leaderboard_entry.dart';

/// ViewModels depend only on this. They never import the concrete implementations.
abstract class LeaderboardRepository {
  /// Live stream of ALL users ranked by the scoring rules. Emits the current
  /// ranking immediately on subscription, then a fresh ranking every time any
  /// user's score changes. The ViewModel derives the top 10 and the current
  /// user's pinned entry from each emission, so the screen updates itself with
  /// no manual refresh. Prefer this over the one-shot [fetchTop10].
  Stream<List<LeaderboardEntry>> watchRankedEntries();

  /// Returns the top [LeaderboardEntry.maxSize] users ranked by scoring rules.
  Future<List<LeaderboardEntry>> fetchTop10();

  /// Returns this user's entry with their actual rank across ALL users.
  /// Used to show a pinned row when the current user is outside the top 10.
  /// Returns null if the user has no record yet.
  Future<LeaderboardEntry?> fetchUserEntry(String userId);
}

import '../../../models/leaderboard_entry.dart';

/// ViewModels depend only on this. They never import the concrete implementations.
abstract class LeaderboardRepository {
  /// Returns the top [LeaderboardEntry.maxSize] users ranked by scoring rules.
  Future<List<LeaderboardEntry>> fetchTop10();

  /// Returns this user's entry with their actual rank across ALL users.
  /// Used to show a pinned row when the current user is outside the top 10.
  /// Returns null if the user has no record yet.
  Future<LeaderboardEntry?> fetchUserEntry(String userId);
}

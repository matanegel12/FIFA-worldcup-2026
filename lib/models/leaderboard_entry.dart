/// A single row in the leaderboard. Computed by the leaderboard repository
/// from sorted User objects — never stored in Firestore.
///
/// Sorting rules (applied in order):
///   1. totalPoints descending
///   2. scoreReachedAt ascending  — who reached this score first
///   3. earliestGuessAt ascending — who submitted their guess first (for the tying game)
class LeaderboardEntry {
  /// Maximum number of entries shown in the leaderboard.
  static const int maxSize = 10;

  final int rank;
  final String userId;
  final String displayName;
  final int totalPoints;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalPoints,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardEntry && other.userId == userId);

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'LeaderboardEntry(#$rank, $displayName, $totalPoints pts)';
}

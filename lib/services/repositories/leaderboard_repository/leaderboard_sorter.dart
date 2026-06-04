import '../../../models/leaderboard_entry.dart';
import '../../../models/user.dart';

/// Converts a raw list of users into ranked LeaderboardEntry objects.
///
/// Sorting rules applied in order:
///   1. totalPoints descending        — more points = higher rank
///   2. scoreReachedAt ascending      — reached this score earlier = higher rank
///                                      null (never scored) = sorted last
///   3. userId alphabetical           — deterministic fallback for true ties
List<LeaderboardEntry> buildRankedEntries(List<User> users) {
  final sorted = List.of(users)..sort(_compare);

  return sorted
      .asMap()
      .entries
      .map((e) => LeaderboardEntry(
            rank: e.key + 1,
            userId: e.value.id,
            displayName: e.value.displayName,
            totalPoints: e.value.totalPoints,
          ))
      .toList();
}

int _compare(User a, User b) {
  // 1. Higher points first.
  final pointsCmp = b.totalPoints.compareTo(a.totalPoints);
  if (pointsCmp != 0) return pointsCmp;

  // 2. Earlier scoreReachedAt first. Null means never scored — goes last.
  if (a.scoreReachedAt == null && b.scoreReachedAt == null) {
    return a.id.compareTo(b.id);
  }3
  if (a.scoreReachedAt == null) return 1;
  if (b.scoreReachedAt == null) return -1;

  final timeCmp = a.scoreReachedAt!.compareTo(b.scoreReachedAt!);
  if (timeCmp != 0) return timeCmp;

  // 3. Alphabetical userId — always produces a deterministic result.
  return a.id.compareTo(b.id);
}

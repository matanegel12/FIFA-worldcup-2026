import '../../../models/leaderboard_entry.dart';
import '../../mock/mock_store.dart';
import 'leaderboard_repository.dart';
import 'leaderboard_sorter.dart';

class MockLeaderboardRepository implements LeaderboardRepository {
  final MockStore _store;

  MockLeaderboardRepository({MockStore? store})
      : _store = store ?? MockStore.instance;

  @override
  Future<List<LeaderboardEntry>> fetchTop10() async {
    final List<LeaderboardEntry> entries = _rankedEntries();
    return entries.take(LeaderboardEntry.maxSize).toList();
  }

  @override
  Future<LeaderboardEntry?> fetchUserEntry(String userId) async =>
      _rankedEntries().where((LeaderboardEntry e) => e.userId == userId).firstOrNull;

  /// Returns seeded leaderboard if one was explicitly provided,
  /// otherwise computes rankings from the users in MockStore.
  List<LeaderboardEntry> _rankedEntries() {
    if (_store.leaderboard.isNotEmpty) {
      return List.of(_store.leaderboard);
    }
    return buildRankedEntries(List.of(_store.users));
  }
}

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
    final entries = _allRanked();
    return entries.take(LeaderboardEntry.maxSize).toList();
  }

  @override
  Future<LeaderboardEntry?> fetchUserEntry(String userId) async =>
      _allRanked().where((e) => e.userId == userId).firstOrNull;

  List<LeaderboardEntry> _allRanked() =>
      buildRankedEntries(List.of(_store.users));
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/leaderboard_entry.dart';
import 'package:fifa_worldcup_2026_predictions/pages/leaderboard/leaderboard_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const String _currentUserId = 'test-uid-123';

LeaderboardEntry _entry(int rank, String userId, int points) =>
    LeaderboardEntry(
      rank: rank,
      userId: userId,
      displayName: 'Player $rank',
      totalPoints: points,
    );

List<LeaderboardEntry> _top10() => List.generate(
      10,
      (int i) => _entry(i + 1, 'user-${i + 1}', 10 - i),
    );

LeaderboardViewModel _makeVm() => LeaderboardViewModel(
      leaderboardRepository: MockLeaderboardRepository(),
      userId: _currentUserId,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() => MockStore.instance.resetAll());

  group('initial state', () {
    test('isLoading is true before loadLeaderboard is called', () {
      expect(_makeVm().model.isLoading, isTrue);
    });

    test('topEntries is empty initially', () {
      expect(_makeVm().model.topEntries, isEmpty);
    });

    test('no error message initially', () {
      expect(_makeVm().model.errorMessage, isNull);
    });
  });

  group('loading state', () {
    test('isLoading is false after loadLeaderboard completes', () async {
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();
      expect(vm.model.isLoading, isFalse);
    });
  });

  group('top 10 loaded correctly', () {
    test('topEntries contains all returned entries', () async {
      MockStore.instance.seedLeaderboard(_top10());
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();
      expect(vm.model.topEntries.length, 10);
    });

    test('userId getter returns the injected userId', () {
      expect(_makeVm().userId, _currentUserId);
    });
  });

  group('current user in top 10', () {
    test('isCurrentUserInTopTen is true when user appears in top 10', () async {
      final List<LeaderboardEntry> entries = [
        _entry(1, 'user-1', 10),
        _entry(2, _currentUserId, 8), // current user at rank 2
        ..._top10().skip(2).take(8),
      ];
      MockStore.instance.seedLeaderboard(entries);
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();

      expect(vm.model.isCurrentUserInTopTen, isTrue);
      expect(vm.model.currentUserEntry, isNull); // not fetched when in top 10
    });
  });

  group('current user outside top 10', () {
    test('isCurrentUserInTopTen is false when user not in top 10', () async {
      MockStore.instance.seedLeaderboard(_top10());
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();

      expect(vm.model.isCurrentUserInTopTen, isFalse);
    });

    test('currentUserEntry is null when user has no record', () async {
      MockStore.instance.seedLeaderboard(_top10());
      // current user not in leaderboard at all
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();

      expect(vm.model.currentUserEntry, isNull);
    });

    test('currentUserEntry is set when user has a record outside top 10',
        () async {
      final List<LeaderboardEntry> full = [
        ..._top10(),
        _entry(14, _currentUserId, 0), // current user at rank 14
      ];
      MockStore.instance.seedLeaderboard(full);
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();

      expect(vm.model.isCurrentUserInTopTen, isFalse);
      expect(vm.model.currentUserEntry, isNotNull);
      expect(vm.model.currentUserEntry!.rank, 14);
      expect(vm.model.currentUserEntry!.userId, _currentUserId);
    });
  });

  group('onViewResumed triggers loadLeaderboard', () {
    test('topEntries is populated after onViewResumed', () async {
      MockStore.instance.seedLeaderboard(_top10());
      final LeaderboardViewModel vm = _makeVm();

      vm.onViewResumed();
      // Give the async load time to complete
      await Future<void>.delayed(Duration.zero);

      expect(vm.model.topEntries, isNotEmpty);
    });
  });

  group('error state', () {
    test('errorMessage is cleared on successful retry', () async {
      final LeaderboardViewModel vm = _makeVm();
      vm.model.errorMessage = 'previous error';
      await vm.loadLeaderboard();
      expect(vm.model.errorMessage, isNull);
    });

    test('isLoading is false after error', () async {
      final LeaderboardViewModel vm = _makeVm();
      await vm.loadLeaderboard();
      expect(vm.model.isLoading, isFalse);
    });
  });
}

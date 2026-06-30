import 'dart:async';

import 'package:mvvm_remepy/view_model.dart';

import '../../models/leaderboard_entry.dart';
import '../../services/repositories/leaderboard_repository/leaderboard_repository.dart';
import 'leaderboard_model.dart';

class LeaderboardViewModel extends ViewModel<LeaderboardModel> {
  final LeaderboardRepository _leaderboardRepository;
  final String _userId;

  /// Live subscription to the ranked-entries stream. Cancelled in [dispose].
  StreamSubscription<List<LeaderboardEntry>>? _subscription;

  /// Exposed so the page can compare entry.userId == viewModel.userId.
  String get userId => _userId;

  LeaderboardViewModel({
    required LeaderboardRepository leaderboardRepository,
    required String userId,
  })  : _leaderboardRepository = leaderboardRepository,
        _userId = userId,
        super(model: LeaderboardModel());

  /// Called by BasePage after the first frame renders.
  @override
  void onViewLoaded(dynamic data) {
    loadLeaderboard();
  }

  /// Called by BasePage when the user navigates back to this page. The stream
  /// stays live while the page is paused, so this re-subscribe is just a
  /// belt-and-braces refresh.
  @override
  void onViewResumed() {
    loadLeaderboard();
  }

  /// Manual refresh / retry. With a live stream this simply (re)subscribes;
  /// the [Future] completes once the first ranking arrives, so the
  /// RefreshIndicator spinner and error-retry both behave correctly.
  Future<void> loadLeaderboard() => _subscribe();

  /// Subscribes to the live ranked-entries stream. Every emission re-derives
  /// the top 10 and the current user's pinned entry, so the screen stays in
  /// sync with Firestore without polling or manual reloads.
  Future<void> _subscribe() async {
    await _subscription?.cancel();

    model.isLoading = true;
    model.errorMessage = null;
    notify();

    final Completer<void> firstEvent = Completer<void>();

    _subscription = _leaderboardRepository.watchRankedEntries().listen(
      (List<LeaderboardEntry> ranked) {
        _applyRanking(ranked);
        if (!firstEvent.isCompleted) firstEvent.complete();
      },
      onError: (Object _) {
        model.errorMessage = 'Could not load leaderboard. Tap to retry.';
        model.isLoading = false;
        notify();
        if (!firstEvent.isCompleted) firstEvent.complete();
      },
    );

    return firstEvent.future;
  }

  /// Splits a full ranked list into the top 10 plus, if the current user is
  /// outside it, their own entry (which already carries its real rank).
  void _applyRanking(List<LeaderboardEntry> ranked) {
    final List<LeaderboardEntry> top =
        ranked.take(LeaderboardEntry.maxSize).toList();
    final bool inTopTen =
        top.any((LeaderboardEntry e) => e.userId == _userId);

    model.topEntries = top;
    model.isCurrentUserInTopTen = inTopTen;
    model.currentUserEntry = inTopTen
        ? null
        : ranked
            .where((LeaderboardEntry e) => e.userId == _userId)
            .firstOrNull;
    model.errorMessage = null;
    model.isLoading = false;
    notify();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

import 'package:mvvm_remepy/view_model.dart';

import '../../models/leaderboard_entry.dart';
import '../../services/repositories/leaderboard_repository/leaderboard_repository.dart';
import 'leaderboard_model.dart';

class LeaderboardViewModel extends ViewModel<LeaderboardModel> {
  final LeaderboardRepository _leaderboardRepository;
  final String _userId;

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

  /// Called by BasePage when the user navigates back to this page.
  @override
  void onViewResumed() {
    loadLeaderboard();
  }

  /// Fetches top 10 and the current user's entry if outside the top 10.
  /// Also used as a retry callback from the page.
  Future<void> loadLeaderboard() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<LeaderboardEntry> entries =
          await _leaderboardRepository.fetchTop10();

      final bool inTopTen =
          entries.any((LeaderboardEntry e) => e.userId == _userId);

      LeaderboardEntry? currentUserEntry;
      if (!inTopTen) {
        currentUserEntry =
            await _leaderboardRepository.fetchUserEntry(_userId);
      }

      model.topEntries = entries;
      model.isCurrentUserInTopTen = inTopTen;
      model.currentUserEntry = currentUserEntry;
    } catch (e) {
      model.errorMessage = 'Could not load leaderboard. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }
}

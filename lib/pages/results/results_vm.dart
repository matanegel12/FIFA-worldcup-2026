import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import 'results_model.dart';

class ResultsViewModel extends ViewModel<ResultsModel> {
  final GamesRepository _gamesRepository;

  ResultsViewModel({required GamesRepository gamesRepository})
      : _gamesRepository = gamesRepository,
        super(model: ResultsModel());

  /// Called by BasePage after the first frame renders.
  @override
  void onViewLoaded(dynamic data) {
    loadResults();
  }

  /// Fetches all finished games sorted by kickoff time ascending.
  /// Also used as a retry callback from the page.
  Future<void> loadResults() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<Game> games = await _gamesRepository.fetchFinishedGames();

      games.sort(
        (Game a, Game b) => a.kickoffTime.compareTo(b.kickoffTime),
      );

      model.finishedGames = games;
    } catch (e) {
      model.errorMessage = 'Could not load results. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }
}

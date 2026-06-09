import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import 'results_model.dart';

class ResultsViewModel extends ViewModel<ResultsModel> {
  final GamesRepository _gamesRepository;

  ResultsViewModel({required GamesRepository gamesRepository})
      : _gamesRepository = gamesRepository,
        super(model: ResultsModel());

  @override
  void onViewLoaded(dynamic data) {
    loadResults();
  }

  Future<void> loadResults() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<Game> allGames = await _gamesRepository.fetchFinishedGames();
      allGames.sort((Game a, Game b) => a.kickoffTime.compareTo(b.kickoffTime));
      model.finishedGames = allGames;
      model.isLoading = false;
      notify();
    } catch (e) {
      model.errorMessage = 'Could not load results. Please try again.';
      model.isLoading = false;
      notify();
    }
  }
}

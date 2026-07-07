import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/prediction_summary.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import 'predictions_model.dart';

class PredictionsViewModel extends ViewModel<PredictionsModel> {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;
  final String _userId;

  PredictionsViewModel({
    required GamesRepository gamesRepository,
    required GuessesRepository guessesRepository,
    required String userId,
  })  : _gamesRepository = gamesRepository,
        _guessesRepository = guessesRepository,
        _userId = userId,
        super(model: PredictionsModel());

  /// Called by BasePage after the first frame renders.
  @override
  void onViewLoaded(dynamic data) {
    loadPredictions();
  }

  /// Loads all games and the user's guesses, builds PredictionSummary list.
  /// Every game appears — games without a guess show notGuessed.
  /// Also used as a retry callback from the page.
  Future<void> loadPredictions() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<Game> allGames = await _gamesRepository.fetchAllGames();
      final List<Guess> userGuesses =
          await _guessesRepository.fetchGuessesForUser(_userId);

      final Map<String, Guess> guessesById = {
        for (final Guess g in userGuesses) g.gameId: g,
      };

      final List<PredictionSummary> summaries = [];

      for (final Game game in allGames) {
        final Guess? guess = guessesById[game.id];
        final PredictionResult result = _determineResult(game, guess);
        summaries.add(PredictionSummary(game: game, guess: guess, result: result));
      }

      // Latest kickoff first, so the newest games are at the top of the list.
      summaries.sort(
        (PredictionSummary a, PredictionSummary b) =>
            b.game.kickoffTime.compareTo(a.game.kickoffTime),
      );

      model.predictions = summaries;
    } catch (e) {
      model.errorMessage = 'Could not load predictions. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  PredictionResult _determineResult(Game game, Guess? guess) {
    if (guess == null) return PredictionResult.notGuessed;
    if (!game.isFinished) return PredictionResult.pending;
    if (game.outcome == guess.prediction) return PredictionResult.correct;
    return PredictionResult.incorrect;
  }
}

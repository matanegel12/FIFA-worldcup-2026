import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/round_group.dart';
import '../../services/matchday_service.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import 'upcoming_games_model.dart';

class UpcomingGamesViewModel extends ViewModel<UpcomingGamesModel> {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;
  final String _userId;

  UpcomingGamesViewModel({
    required GamesRepository gamesRepository,
    required GuessesRepository guessesRepository,
    required String userId,
  })  : _gamesRepository = gamesRepository,
        _guessesRepository = guessesRepository,
        _userId = userId,
        super(model: UpcomingGamesModel());

  /// Called by BasePage after the first frame renders.
  @override
  void onViewLoaded(dynamic data) {
    loadGames();
  }

  /// Fetches upcoming games (kickoff in the future) and the user's existing guesses.
  /// Also used as a retry callback from the page.
  Future<void> loadGames() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<Game> upcomingGames =
          await _gamesRepository.fetchUpcomingGames();

      final List<Guess> userGuesses =
          await _guessesRepository.fetchGuessesForUser(_userId);

      model.groupedGames = _buildGroupedGames(upcomingGames);
      model.guesses = {
        for (final Guess g in userGuesses) g.gameId: g,
      };
    } catch (e) {
      model.errorMessage = 'Could not load games. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  /// Saves a prediction for a game and immediately updates the model
  /// so the page rebuilds with the new selection visible.
  Future<void> onPredictionChanged(
      String gameId, Prediction prediction) async {
    final Guess newGuess = Guess(
      userId: _userId,
      gameId: gameId,
      prediction: prediction,
    );

    try {
      await _guessesRepository.saveGuess(newGuess);
      model.guesses[gameId] = newGuess;
      notify();
    } catch (e) {
      // Silently fail — the card stays in its previous visual state.
    }
  }

  List<RoundGroup> _buildGroupedGames(List<Game> futureGames) {
    final Map<String, List<Game>> byRound = {};
    for (final Game game in futureGames) {
      byRound.putIfAbsent(game.round, () => []).add(game);
    }

    final List<String> rounds = sortedRounds(futureGames);
    final List<RoundGroup> result = [];

    for (int i = 0; i < rounds.length; i++) {
      final String round = rounds[i];
      final List<Game> games = byRound[round]!;
      result.add(RoundGroup(
        round: round,
        date: DateTime.utc(
          games.first.kickoffTime.year,
          games.first.kickoffTime.month,
          games.first.kickoffTime.day,
        ),
        isUnlocked: i == 0,
        games: games,
      ));
    }

    return result;
  }
}

import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/round_group.dart';
import '../../models/user.dart';
import '../../services/matchday_service.dart';
import '../../services/scoring/scoring_calculator.dart';
import '../../services/repositories/auth_repository/auth_repository.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import 'upcoming_games_model.dart';

class UpcomingGamesViewModel extends ViewModel<UpcomingGamesModel> {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;
  final AuthRepository _authRepository;
  final String _userId;

  bool _hasShownPopup = false;

  UpcomingGamesViewModel({
    required GamesRepository gamesRepository,
    required GuessesRepository guessesRepository,
    required AuthRepository authRepository,
    required String userId,
  })  : _gamesRepository = gamesRepository,
        _guessesRepository = guessesRepository,
        _authRepository = authRepository,
        _userId = userId,
        super(model: UpcomingGamesModel());

  @override
  void onViewLoaded(dynamic data) {
    loadGames();
  }

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

      if (!_hasShownPopup) {
        await _checkUnseenResults();
      }
    } catch (e) {
      model.errorMessage = 'Could not load games. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  Future<void> onSignOut() async {
    await _authRepository.signOut();
    notifyNavigate(NavigateModel(routeName: '/sign-in', replace: true));
  }

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

  Future<void> onPopupDismissed() async {
    model.showResultsPopup = false;
    model.unseenGames = [];
    notifyNavigate(NavigateModel(routeName: ''));
    await _updateLastVisitedAt();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _checkUnseenResults() async {
    final User? user = await _authRepository.getCurrentUser();
    if (user == null) return;

    final List<Game> allFinished =
        await _gamesRepository.fetchFinishedGames();

    final List<Game> unseen = user.lastVisitedAt == null
        ? []
        : allFinished
            .where((Game g) =>
                g.finishedAt != null &&
                g.finishedAt!.isAfter(user.lastVisitedAt!))
            .toList();

    if (unseen.isEmpty) return;

    _hasShownPopup = true;
    model.unseenGames = unseen;
    model.showResultsPopup = true;
    notify();
  }

  Future<void> _updateLastVisitedAt() async {
    await _authRepository.updateLastVisited(_userId, DateTime.now().toUtc());
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
      final bool isKnockout = usesKnockoutRules(games.first);
      result.add(RoundGroup(
        round: round,
        date: DateTime.utc(
          games.first.kickoffTime.year,
          games.first.kickoffTime.month,
          games.first.kickoffTime.day,
        ),
        isKnockout: isKnockout,
        pointsPerGame: isKnockout ? pointsForKnockoutRound(round) : 1,
        games: games,
      ));
    }

    return result;
  }
}

import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/score_summary.dart';
import '../../models/user.dart';
// TODO: switch to FirestoreGamesRepository and FirestoreGuessesRepository
// before production — remove mock dependencies
import '../../services/mock/mock_store.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/games_repository/mock_games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import '../../services/repositories/guesses_repository/mock_guesses_repository.dart';
import '../../services/scoring/scoring_calculator.dart';
import 'admin_panel_model.dart';

class AdminPanelViewModel extends ViewModel<AdminPanelModel> {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;

  AdminPanelViewModel({
    GamesRepository? gamesRepository,
    GuessesRepository? guessesRepository,
  })  : _gamesRepository = gamesRepository ?? MockGamesRepository(),
        _guessesRepository = guessesRepository ?? MockGuessesRepository(),
        super(model: AdminPanelModel());

  @override
  void onViewLoaded(dynamic data) {
    loadGames();
  }

  Future<void> loadGames() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final List<Game> allGames = await _gamesRepository.fetchAllGames();
      final DateTime now = DateTime.now().toUtc();

      // Games that need a result: kickoff has passed and no score recorded yet.
      model.gamesNeedingResults = allGames
          .where((Game g) =>
              g.kickoffTime.isBefore(now) && g.homeScore == null)
          .toList();
    } catch (e) {
      model.errorMessage = 'Could not load games. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  /// Saves the final score, recomputes every user's total points, then reloads.
  Future<void> setGameResult(
    String gameId,
    int homeScore,
    int awayScore,
  ) async {
    model.isLoading = true;
    model.successMessage = null;
    model.errorMessage = null;
    notify();

    try {
      final DateTime finishedAt = DateTime.now().toUtc();

      await _gamesRepository.recordResult(
        gameId: gameId,
        homeScore: homeScore,
        awayScore: awayScore,
        finishedAt: finishedAt,
      );

      await _rescoreAllUsers();

      model.successMessage = 'Result saved ✅';
    } catch (e) {
      model.errorMessage = 'Failed to save result. Try again.';
    } finally {
      model.isLoading = false;
      notify();
    }

    await loadGames();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _rescoreAllUsers() async {
    final List<Game> finishedGames =
        await _gamesRepository.fetchFinishedGames();

    final List<User> allUsers = MockStore.instance.users;

    for (final User user in allUsers) {
      final List<Guess> userGuesses =
          await _guessesRepository.fetchGuessesForUser(user.id);

      final ScoreSummary summary = calculate(
        userId: user.id,
        finishedGames: finishedGames,
        userGuesses: userGuesses,
      );

      final User updatedUser = User(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        totalPoints: summary.totalPoints,
        scoreReachedAt: summary.totalPoints > user.totalPoints
            ? DateTime.now().toUtc()
            : user.scoreReachedAt,
        lastVisitedAt: user.lastVisitedAt,
      );
      MockStore.instance.saveUser(updatedUser);
      MockStore.instance.updateLeaderboardPoints(user.id, summary.totalPoints);
    }
  }
}

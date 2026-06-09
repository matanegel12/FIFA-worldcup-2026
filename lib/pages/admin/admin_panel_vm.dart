import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/score_summary.dart';
import '../../models/user.dart';
import '../../services/repositories/games_repository/firestore_games_repository.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/firestore_guesses_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import '../../services/scoring/scoring_calculator.dart';
import 'admin_panel_model.dart';

class AdminPanelViewModel extends ViewModel<AdminPanelModel> {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;
  final FirebaseFirestore _firestore;

  AdminPanelViewModel({
    GamesRepository? gamesRepository,
    GuessesRepository? guessesRepository,
    FirebaseFirestore? firestore,
  })  : _gamesRepository = gamesRepository ?? FirestoreGamesRepository(),
        _guessesRepository = guessesRepository ?? FirestoreGuessesRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance,
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

    final QuerySnapshot<Map<String, dynamic>> usersSnap =
        await _firestore.collection('users').get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in usersSnap.docs) {
      final User user = User.fromJson(doc.id, doc.data());

      final List<Guess> userGuesses =
          await _guessesRepository.fetchGuessesForUser(user.id);

      final ScoreSummary summary = calculate(
        userId: user.id,
        finishedGames: finishedGames,
        userGuesses: userGuesses,
      );

      await _firestore.collection('users').doc(user.id).update({
        'totalPoints': summary.totalPoints,
        'scoreReachedAt': summary.totalPoints > user.totalPoints
            ? DateTime.now().toUtc().toIso8601String()
            : user.scoreReachedAt?.toIso8601String(),
      });
    }
  }
}

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

      model.allGames = allGames;
      model.gamesNeedingResults = allGames
          .where((Game g) =>
              g.kickoffTime.isBefore(now) &&
              g.homeScore == null &&
              !g.isTestResult)
          .toList();
    } catch (e) {
      model.errorMessage = 'Could not load games. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  /// Saves a real final score, rescores all users, then reloads.
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

  // ── Score Testing ─────────────────────────────────────────────────────────

  /// Writes a test score to a game (flagged isTestResult = true),
  /// then runs the same production scoring path as a real result.
  Future<void> forceGameResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
  }) async {
    model.savingGameIds = {...model.savingGameIds, gameId};
    model.successMessage = null;
    model.errorMessage = null;
    notify();

    try {
      final DateTime finishedAt = DateTime.now().toUtc();

      await _firestore.collection('games').doc(gameId).update({
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': GameStatus.finished.name,
        'finishedAt': finishedAt.toIso8601String(),
        'isTestResult': true,
      });

      await _rescoreAllUsers();
      model.successMessage = 'Test score applied ✅';
    } catch (e) {
      model.errorMessage = 'Failed to apply test score. Try again.';
    } finally {
      model.savingGameIds = {...model.savingGameIds}..remove(gameId);
      notify();
    }

    await loadGames();
  }

  /// Resets all test-flagged games to upcoming, then recomputes every user's
  /// score from only real finished games.
  Future<void> clearTestResults() async {
    model.isLoading = true;
    model.successMessage = null;
    model.errorMessage = null;
    notify();

    try {
      final QuerySnapshot<Map<String, dynamic>> testSnap = await _firestore
          .collection('games')
          .where('isTestResult', isEqualTo: true)
          .get();

      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in testSnap.docs) {
        batch.update(doc.reference, {
          'homeScore': FieldValue.delete(),
          'awayScore': FieldValue.delete(),
          'status': GameStatus.upcoming.name,
          'finishedAt': FieldValue.delete(),
          'isTestResult': FieldValue.delete(),
        });
      }
      await batch.commit();

      await recomputeAllScores();
      model.successMessage = 'Test scores cleared and points recomputed ✅';
    } catch (e) {
      model.errorMessage = 'Failed to clear test scores. Try again.';
    } finally {
      model.isLoading = false;
      notify();
    }

    await loadGames();
  }

  /// Resets every user to 0 pts, then rescores from all real (non-test)
  /// finished games using the production scoring path.
  Future<void> recomputeAllScores() async {
    final QuerySnapshot<Map<String, dynamic>> usersSnap =
        await _firestore.collection('users').get();

    // Step 1 — reset all users to 0.
    final WriteBatch resetBatch = _firestore.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in usersSnap.docs) {
      resetBatch.update(doc.reference, {
        'totalPoints': 0,
        'scoreReachedAt': null,
      });
    }
    await resetBatch.commit();

    // Step 2 — fetch only real finished games (exclude test results).
    final List<Game> allFinished =
        await _gamesRepository.fetchFinishedGames();
    final List<Game> realFinished =
        allFinished.where((Game g) => !g.isTestResult).toList();

    if (realFinished.isEmpty) return;

    // Step 3 — rescore each user with the production scoring function.
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in usersSnap.docs) {
      final User user = User.fromJson(doc.id, doc.data());

      final List<Guess> userGuesses =
          await _guessesRepository.fetchGuessesForUser(user.id);

      final ScoreSummary summary = calculate(
        userId: user.id,
        finishedGames: realFinished,
        userGuesses: userGuesses,
      );

      await _firestore.collection('users').doc(user.id).update({
        'totalPoints': summary.totalPoints,
        'scoreReachedAt': summary.totalPoints > 0
            ? DateTime.now().toUtc().toIso8601String()
            : null,
      });
    }
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

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

/// One pending write to a user document: the doc reference and the fields to set.
/// Collected during the read/compute phase, then flushed together in one batch.
typedef _UserScoreUpdate = ({
  DocumentReference<Map<String, dynamic>> ref,
  Map<String, dynamic> data,
});

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

  /// Recomputes every user's score from scratch, using only real (non-test)
  /// finished games. Each user is fully recomputed, so there is no separate
  /// "reset to 0" step — a user with no correct guesses simply computes to 0.
  /// All writes land in one atomic batch (see [_commitUserUpdates]).
  Future<void> recomputeAllScores() async {
    final QuerySnapshot<Map<String, dynamic>> usersSnap =
        await _firestore.collection('users').get();

    // Fetch only real finished games (exclude test results).
    final List<Game> allFinished =
        await _gamesRepository.fetchFinishedGames();
    final List<Game> realFinished =
        allFinished.where((Game g) => !g.isTestResult).toList();

    final DateTime now = DateTime.now().toUtc();

    // Phase 1 — compute every user's new score (reads only, no writes yet).
    final List<_UserScoreUpdate> updates = [];
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

      updates.add((
        ref: doc.reference,
        data: {
          'totalPoints': summary.totalPoints,
          'scoreReachedAt':
              summary.totalPoints > 0 ? now.toIso8601String() : null,
        },
      ));
    }

    // Phase 2 — flush all updates in one atomic commit.
    await _commitUserUpdates(updates);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _rescoreAllUsers() async {
    final List<Game> finishedGames =
        await _gamesRepository.fetchFinishedGames();

    final QuerySnapshot<Map<String, dynamic>> usersSnap =
        await _firestore.collection('users').get();

    final DateTime now = DateTime.now().toUtc();

    // Phase 1 — read each user's guesses and compute their new total. No writes
    // happen here, so the leaderboard still reflects a fully consistent old state.
    final List<_UserScoreUpdate> updates = [];
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

      updates.add((
        ref: doc.reference,
        data: {
          'totalPoints': summary.totalPoints,
          // Advance scoreReachedAt only when the score actually went up — this
          // is the tiebreaker (earliest to reach a score ranks higher).
          'scoreReachedAt': summary.totalPoints > user.totalPoints
              ? now.toIso8601String()
              : user.scoreReachedAt?.toIso8601String(),
        },
      ));
    }

    // Phase 2 — commit every user's new total together.
    await _commitUserUpdates(updates);
  }

  /// Flushes all collected user-score updates in one atomic [WriteBatch], so a
  /// client reading the leaderboard sees either all of the old totals or all of
  /// the new ones — never a half-updated mix. Firestore caps a batch at 500
  /// writes, so we chunk defensively if the user count ever grows past that
  /// (each chunk is its own atomic commit; below 500 users it is a single one).
  Future<void> _commitUserUpdates(List<_UserScoreUpdate> updates) async {
    const int batchLimit = 500;
    for (int i = 0; i < updates.length; i += batchLimit) {
      final WriteBatch batch = _firestore.batch();
      for (final _UserScoreUpdate update in updates.skip(i).take(batchLimit)) {
        batch.update(update.ref, update.data);
      }
      await batch.commit();
    }
  }
}

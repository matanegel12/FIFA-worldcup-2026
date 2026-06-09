import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/score_summary.dart';
import '../../models/user.dart';
import '../repositories/auth_repository/auth_repository.dart';
import '../repositories/games_repository/games_repository.dart';
import '../repositories/guesses_repository/guesses_repository.dart';
import 'scoring_calculator.dart';

/// Recomputes the current user's score from finished games and saves it
/// to Firestore. Called on app startup after a successful game sync.
class UserScoreSyncService {
  final GamesRepository _gamesRepository;
  final GuessesRepository _guessesRepository;
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  UserScoreSyncService({
    required GamesRepository gamesRepository,
    required GuessesRepository guessesRepository,
    required AuthRepository authRepository,
    FirebaseFirestore? firestore,
  })  : _gamesRepository = gamesRepository,
        _guessesRepository = guessesRepository,
        _authRepository = authRepository,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> syncCurrentUserScore() async {
    final User? user = await _authRepository.getCurrentUser();
    if (user == null) return;

    final List<Game> finishedGames =
        await _gamesRepository.fetchFinishedGames();
    if (finishedGames.isEmpty) return;

    final List<Guess> userGuesses =
        await _guessesRepository.fetchGuessesForUser(user.id);
    if (userGuesses.isEmpty) return;

    // scoring_calculator.dart exports a top-level function, not a class.
    final ScoreSummary summary = calculate(
      userId: user.id,
      finishedGames: finishedGames,
      userGuesses: userGuesses,
    );

    await _firestore.collection('users').doc(user.id).update({
      'totalPoints': summary.totalPoints,
      'scoreReachedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

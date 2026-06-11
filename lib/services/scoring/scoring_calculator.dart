import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/score_summary.dart';

/// Calculates a user's score from their guesses against finished game results.
///
/// Call this after a game finishes — pass only finished games with a known outcome.
/// The result is a [ScoreSummary] used to update the user's totalPoints in Firestore.
ScoreSummary calculate({
  required String userId,
  required List<Game> finishedGames,
  required List<Guess> userGuesses,
}) {
  // Index this user's guesses by gameId for O(1) lookup.
  // Filter by userId defensively — callers should pass only one user's guesses,
  // but this prevents accidental cross-user scoring if they don't.
  final guessMap = {
    for (final g in userGuesses.where((g) => g.userId == userId)) g.gameId: g
  };

  int correctGuesses = 0;

  for (final game in finishedGames) {
    final guess = guessMap[game.id];
    if (guess != null && guess.prediction == game.outcome) {
      correctGuesses++;
    }
  }

  // Group finished games by their match day (round field).
  // A set is all games belonging to the same match day.
  final Map<String, List<Game>> gamesByRound = {};
  for (final game in finishedGames) {
    gamesByRound.putIfAbsent(game.round, () => []).add(game);
  }

  int setBonusCount = 0;
  for (final entry in gamesByRound.entries) {
    if (_isPerfectMatchDay(entry.value, guessMap)) {
      setBonusCount++;
    }
  }

  return ScoreSummary(
    userId: userId,
    correctGuesses: correctGuesses,
    setBonusCount: setBonusCount,
  );
}

/// Returns true when the user correctly predicted every game in this match day.
///
/// This is the single definition of a "set". A set is all games in the same
/// match day (round field, e.g. "Matchday 1"). If the user correctly predicted
/// every game in a match day, +2 bonus points are awarded for that match day.
/// To change the bonus rule, change only this function.
bool _isPerfectMatchDay(List<Game> gamesInMatchDay, Map<String, Guess> guessMap) {
  if (gamesInMatchDay.isEmpty) return false;
  return gamesInMatchDay.every((game) {
    final guess = guessMap[game.id];
    return guess != null && guess.prediction == game.outcome;
  });
}

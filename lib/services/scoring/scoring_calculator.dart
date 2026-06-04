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

  // Group finished games by their UTC calendar day.
  final Map<DateTime, List<Game>> gamesByDay = {};
  for (final game in finishedGames) {
    gamesByDay.putIfAbsent(game.matchDay, () => []).add(game);
  }

  int setBonusCount = 0;
  for (final entry in gamesByDay.entries) {
    if (_isPerfectDay(entry.value, guessMap)) {
      setBonusCount++;
    }
  }

  return ScoreSummary(
    userId: userId,
    correctGuesses: correctGuesses,
    setBonusCount: setBonusCount,
  );
}

/// Returns true when the user correctly predicted every game on this day.
///
/// This is the single definition of a "set". To change the bonus rule
/// (e.g. "all games in a group" instead of "all games in a day"),
/// change only this function.
bool _isPerfectDay(List<Game> gamesOnDay, Map<String, Guess> guessMap) {
  if (gamesOnDay.isEmpty) return false;
  return gamesOnDay.every((game) {
    final guess = guessMap[game.id];
    return guess != null && guess.prediction == game.outcome;
  });
}

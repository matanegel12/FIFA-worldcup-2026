import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/score_summary.dart';

/// The instant the knockout stage begins — the single source of truth for the
/// two scoring regimes. Change it here and scoring, the "2 pts" badge, and the
/// 120-min note all follow.
///
/// Games kicking off **before** this use group-stage rules:
///   +1 per correct guess, +2 for a perfect match day (the "set"), grouped by round.
/// Games kicking off **at or after** this use knockout rules:
///   +2 per correct guess, no set bonus, never grouped into match days.
///
/// 2026-06-28 19:00 UTC = Sunday 28 June 2026, 22:00 Israel time (IDT, UTC+3).
final DateTime kKnockoutCutoff = DateTime.utc(2026, 6, 28, 19, 0);

/// True when [game] is scored under knockout rules (kickoff at/after the cutoff).
bool usesKnockoutRules(Game game) =>
    !game.kickoffTime.isBefore(kKnockoutCutoff);

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

  // Split finished games by scoring regime. The cutoff is the only switch.
  final List<Game> groupStageGames =
      finishedGames.where((g) => !usesKnockoutRules(g)).toList();
  final List<Game> knockoutGames =
      finishedGames.where(usesKnockoutRules).toList();

  // Group stage: +1 per correct guess.
  int correctGuesses = 0;
  for (final game in groupStageGames) {
    final guess = guessMap[game.id];
    if (guess != null && guess.prediction == game.outcome) {
      correctGuesses++;
    }
  }

  // Knockout: +2 per correct guess. Counted separately so totalPoints can
  // double them. No match-day grouping, no set bonus.
  int knockoutCorrectGuesses = 0;
  for (final game in knockoutGames) {
    final guess = guessMap[game.id];
    if (guess != null && guess.prediction == game.outcome) {
      knockoutCorrectGuesses++;
    }
  }

  // Set bonus applies to group-stage games only — knockout games never form a
  // set. Group those games by their match day (round field).
  final Map<String, List<Game>> gamesByRound = {};
  for (final game in groupStageGames) {
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
    knockoutCorrectGuesses: knockoutCorrectGuesses,
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

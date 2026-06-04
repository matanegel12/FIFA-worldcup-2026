import '../../../models/guess.dart';

/// ViewModels depend only on this. They never import the concrete implementations.
abstract class GuessesRepository {
  /// Returns this user's guess for a specific game, or null if they haven't guessed.
  Future<Guess?> fetchGuess(String userId, String gameId);

  /// Returns all guesses this user has made across all games.
  Future<List<Guess>> fetchGuessesForUser(String userId);

  /// Returns every user's guess for a specific game.
  /// Used by the scoring engine after a game finishes.
  Future<List<Guess>> fetchGuessesForGame(String gameId);

  /// Saves a guess. If the user already guessed this game, the record is
  /// overwritten — including submittedAt, which always reflects the latest save.
  Future<void> saveGuess(Guess guess);
}

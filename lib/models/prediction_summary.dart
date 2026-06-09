import 'game.dart';
import 'guess.dart';

enum PredictionResult {
  correct,      // game finished, user was right
  incorrect,    // game finished, user was wrong
  pending,      // game not finished yet, user has a guess
  notGuessed,   // user has no guess for this game yet
}

/// A pairing of a game, the user's guess (nullable), and the computed result.
/// Built by [PredictionsViewModel] — the page and card only render it.
class PredictionSummary {
  final Game game;
  final Guess? guess; // null if the user has not predicted this game yet
  final PredictionResult result;

  const PredictionSummary({
    required this.game,
    required this.guess,
    required this.result,
  });

  /// Full score display e.g. "Brazil 2 - 1 Argentina".
  /// Returns empty string when the game has not finished.
  String get resultDisplayText {
    if (game.homeScore == null || game.awayScore == null) return '';
    return '${game.homeTeam.name} ${game.homeScore} - ${game.awayScore} ${game.awayTeam.name}';
  }

  /// Display text for what the user predicted.
  /// Returns "Didn't predict" when the user has not submitted a guess.
  String get predictionDisplayText {
    if (guess == null) return "Didn't predict";
    if (guess!.prediction == Prediction.teamAWins) return game.homeTeam.name;
    if (guess!.prediction == Prediction.teamBWins) return game.awayTeam.name;
    return 'Draw';
  }
}

/// The output of the scoring engine for one user after results are processed.
/// Not stored in Firestore — used to update User.totalPoints and scoreReachedAt.
class ScoreSummary {
  final String userId;

  /// Correct group-stage guesses (kickoff before the knockout cutoff) — +1 each.
  final int correctGuesses;

  /// Points already earned from correct knockout-stage guesses (kickoff at/after
  /// the knockout cutoff). Pre-weighted by round — Round of 32 is +2 per correct
  /// guess, Round of 16 is +3, and so on (see ScoringCalculator.pointsForKnockoutRound)
  /// — because the per-guess value varies by round, unlike the flat +1 group stage.
  /// Defaults to 0 so callers that only deal with the group stage are unaffected.
  final int knockoutPoints;

  /// Completed group-stage sets (perfect match day) — +2 each.
  /// Knockout games never form a set, so they never contribute here.
  final int setBonusCount;

  const ScoreSummary({
    required this.userId,
    required this.correctGuesses,
    this.knockoutPoints = 0,
    required this.setBonusCount,
  });

  /// Group stage: +1 per correct guess, +2 per completed set (perfect match day).
  /// Knockout stage: [knockoutPoints] is already weighted by round, no set bonus.
  int get totalPoints => correctGuesses + knockoutPoints + (setBonusCount * 2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreSummary &&
          other.userId == userId &&
          other.correctGuesses == correctGuesses &&
          other.knockoutPoints == knockoutPoints &&
          other.setBonusCount == setBonusCount);

  @override
  int get hashCode =>
      Object.hash(userId, correctGuesses, knockoutPoints, setBonusCount);

  @override
  String toString() =>
      'ScoreSummary($userId, correct: $correctGuesses, knockoutPoints: $knockoutPoints, setBonuses: $setBonusCount, total: $totalPoints)';
}

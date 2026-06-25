/// The output of the scoring engine for one user after results are processed.
/// Not stored in Firestore — used to update User.totalPoints and scoreReachedAt.
class ScoreSummary {
  final String userId;

  /// Correct group-stage guesses (kickoff before the knockout cutoff) — +1 each.
  final int correctGuesses;

  /// Correct knockout-stage guesses (kickoff at/after the knockout cutoff) — +2 each.
  /// Defaults to 0 so callers that only deal with the group stage are unaffected.
  final int knockoutCorrectGuesses;

  /// Completed group-stage sets (perfect match day) — +2 each.
  /// Knockout games never form a set, so they never contribute here.
  final int setBonusCount;

  const ScoreSummary({
    required this.userId,
    required this.correctGuesses,
    this.knockoutCorrectGuesses = 0,
    required this.setBonusCount,
  });

  /// Group stage: +1 per correct guess, +2 per completed set (perfect match day).
  /// Knockout stage: +2 per correct guess, no set bonus.
  int get totalPoints =>
      correctGuesses + (knockoutCorrectGuesses * 2) + (setBonusCount * 2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreSummary &&
          other.userId == userId &&
          other.correctGuesses == correctGuesses &&
          other.knockoutCorrectGuesses == knockoutCorrectGuesses &&
          other.setBonusCount == setBonusCount);

  @override
  int get hashCode =>
      Object.hash(userId, correctGuesses, knockoutCorrectGuesses, setBonusCount);

  @override
  String toString() =>
      'ScoreSummary($userId, correct: $correctGuesses, knockoutCorrect: $knockoutCorrectGuesses, setBonuses: $setBonusCount, total: $totalPoints)';
}

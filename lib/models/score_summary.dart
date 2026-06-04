/// The output of the scoring engine for one user after results are processed.
/// Not stored in Firestore — used to update User.totalPoints and scoreReachedAt.
class ScoreSummary {
  final String userId;
  final int correctGuesses;
  final int setBonusCount;

  const ScoreSummary({
    required this.userId,
    required this.correctGuesses,
    required this.setBonusCount,
  });

  /// +1 per correct guess, +2 per completed set (all games on the same day correct).
  int get totalPoints => correctGuesses + (setBonusCount * 2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreSummary &&
          other.userId == userId &&
          other.correctGuesses == correctGuesses &&
          other.setBonusCount == setBonusCount);

  @override
  int get hashCode => Object.hash(userId, correctGuesses, setBonusCount);

  @override
  String toString() =>
      'ScoreSummary($userId, correct: $correctGuesses, setBonuses: $setBonusCount, total: $totalPoints)';
}

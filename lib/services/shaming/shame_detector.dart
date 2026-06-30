import '../../models/game.dart';
import '../../models/shame_entry.dart';

/// A guess paired with the SERVER-set time it was written.
///
/// This is the trusted-time input to [detectLateGuesses]. The time here always
/// comes from Firestore's `serverTimestamp()` — never `DateTime.now()` on the
/// device — so the comparison below cannot be defeated by changing the phone's
/// clock.
class TimedGuess {
  final String userId;
  final String gameId;
  final Prediction prediction;
  final DateTime submittedAt; // UTC, server-set

  const TimedGuess({
    required this.userId,
    required this.gameId,
    required this.prediction,
    required this.submittedAt,
  });
}

/// Pure detection logic for the wall of shame — no Firestore, fully unit-tested.
///
/// Keeps every guess whose trusted [TimedGuess.submittedAt] is strictly after
/// the kickoff of its game, and returns the matches sorted by how late they
/// were (latest offenders first).
///
/// A guess is skipped (not flagged) when:
///   - its game is unknown (no entry in [gamesById]), or
///   - it was submitted at or before kickoff (the legitimate case).
///
/// The guess-locking loophole is intentionally NOT closed here — we only
/// observe and report; we never block a late write.
List<ShameEntry> detectLateGuesses({
  required List<TimedGuess> guesses,
  required Map<String, Game> gamesById,
  required Map<String, String> displayNamesByUserId,
}) {
  final List<ShameEntry> shamed = [];

  for (final TimedGuess g in guesses) {
    final Game? game = gamesById[g.gameId];
    if (game == null) continue; // unknown game — cannot judge

    // The whole point: trusted submit time vs. kickoff time from the DB.
    if (!g.submittedAt.isAfter(game.kickoffTime)) continue; // on time

    shamed.add(ShameEntry(
      userId: g.userId,
      displayName: displayNamesByUserId[g.userId] ?? 'Unknown player',
      gameId: g.gameId,
      gameLabel: '${game.homeTeam.name} vs ${game.awayTeam.name}',
      kickoffTime: game.kickoffTime,
      submittedAt: g.submittedAt,
      prediction: g.prediction,
    ));
  }

  // Latest offenders first; stable tiebreak by name then game for determinism.
  shamed.sort((ShameEntry a, ShameEntry b) {
    final int byLateness = b.lateBy.compareTo(a.lateBy);
    if (byLateness != 0) return byLateness;
    final int byName = a.displayName.compareTo(b.displayName);
    if (byName != 0) return byName;
    return a.gameId.compareTo(b.gameId);
  });

  return shamed;
}

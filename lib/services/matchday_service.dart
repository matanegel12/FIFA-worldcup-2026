import '../models/game.dart';

/// Returns unique round strings sorted by each round's earliest kickoff time.
/// Public so the ViewModel can reuse it when building grouped game lists.
///
/// Kickoff time — not the round name — is the source of truth for ordering,
/// matching the rest of the app (see kKnockoutCutoff). A number embedded in
/// the name would be wrong for knockout rounds: "Round of 32" (32) happens
/// before "Round of 16" (16), so sorting by that number ascending would put
/// Round of 16 first.
List<String> sortedRounds(List<Game> games) {
  final Map<String, DateTime> earliestKickoffByRound = {};
  for (final Game game in games) {
    if (game.round.isEmpty) continue;
    final DateTime? earliest = earliestKickoffByRound[game.round];
    if (earliest == null || game.kickoffTime.isBefore(earliest)) {
      earliestKickoffByRound[game.round] = game.kickoffTime;
    }
  }

  final List<String> rounds = earliestKickoffByRound.keys.toList();
  rounds.sort((String a, String b) =>
      earliestKickoffByRound[a]!.compareTo(earliestKickoffByRound[b]!));
  return rounds;
}

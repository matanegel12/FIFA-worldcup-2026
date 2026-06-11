import '../models/game.dart';

/// Returns unique round strings sorted by the number embedded in them.
/// "Matchday 8" → 8, used only for ordering — the raw strings are preserved.
/// Public so the ViewModel can reuse it when building grouped game lists.
List<String> sortedRounds(List<Game> games) {
  final List<String> rounds = games
      .map((Game g) => g.round)
      .where((String r) => r.isNotEmpty)
      .toSet()
      .toList();
  rounds.sort((String a, String b) => _roundNumber(a).compareTo(_roundNumber(b)));
  return rounds;
}

/// Extracts the integer from a round string like "Matchday 8" → 8.
/// Returns 0 if no number is found.
int _roundNumber(String round) {
  final RegExpMatch? match = RegExp(r'\d+').firstMatch(round);
  return match != null ? int.parse(match.group(0)!) : 0;
}

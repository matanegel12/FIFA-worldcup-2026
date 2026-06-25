import 'game.dart';

/// A matchday group ready for the page to render — no processing needed in the View.
///
/// Built by [UpcomingGamesViewModel._buildGroupedGames] after fetching future games.
/// The page only loops over a list of these and renders each one.
class RoundGroup {
  final String round;

  /// Date only — no time component. Always UTC.
  final DateTime date;

  /// True for knockout-stage groups (kickoff at/after the knockout cutoff).
  /// Drives the "2 pts" header badge and the "≈120 min" card note in the View.
  final bool isKnockout;

  final List<Game> games;

  const RoundGroup({
    required this.round,
    required this.date,
    required this.games,
    this.isKnockout = false,
  });
}

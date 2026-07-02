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
  /// Drives the "≈120 min" card note and the round-only (no date) header in the View.
  final bool isKnockout;

  /// Points awarded per correct guess in this round. 1 for group-stage rounds;
  /// for knockout rounds this is [pointsForKnockoutRound] and drives the
  /// header's points badge (e.g. "3 pts" for Round of 16).
  final int pointsPerGame;

  final List<Game> games;

  const RoundGroup({
    required this.round,
    required this.date,
    required this.games,
    this.isKnockout = false,
    this.pointsPerGame = 1,
  });
}

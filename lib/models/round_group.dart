import 'game.dart';

/// A matchday group ready for the page to render — no processing needed in the View.
///
/// Built by [UpcomingGamesViewModel._buildGroupedGames] after fetching future games.
/// The page only loops over a list of these and renders each one.
class RoundGroup {
  final String round;

  /// Date only — no time component. Always UTC.
  final DateTime date;

  final bool isUnlocked;
  final List<Game> games;

  const RoundGroup({
    required this.round,
    required this.date,
    required this.isUnlocked,
    required this.games,
  });
}

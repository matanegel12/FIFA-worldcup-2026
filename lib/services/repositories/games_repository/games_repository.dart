import '../../../models/game.dart';

/// ViewModels depend only on this. They never import the concrete implementations.
abstract class GamesRepository {
  /// All games sorted by kickoff time ascending.
  Future<List<Game>> fetchAllGames();

  /// Games that have not yet started, sorted by kickoff time ascending.
  Future<List<Game>> fetchUpcomingGames();

  /// Games that have finished (have a recorded result).
  Future<List<Game>> fetchFinishedGames();

  /// Saves a full game document. Used when syncing fixtures from the API.
  Future<void> saveGame(Game game);

  /// Records a final result for an existing game and sets finishedAt precisely.
  /// Called by the admin panel and the scoring engine — never by the API parser.
  Future<void> recordResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
    required DateTime finishedAt,
  });
}

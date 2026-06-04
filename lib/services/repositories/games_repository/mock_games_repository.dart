import '../../../models/game.dart';
import '../../mock/mock_store.dart';
import 'games_repository.dart';

class MockGamesRepository implements GamesRepository {
  final MockStore _store;

  MockGamesRepository({MockStore? store})
      : _store = store ?? MockStore.instance;

  @override
  Future<List<Game>> fetchAllGames() async {
    final games = List.of(_store.games)
      ..sort((a, b) => a.kickoffTime.compareTo(b.kickoffTime));
    return games;
  }

  @override
  Future<List<Game>> fetchUpcomingGames() async {
    final games = List.of(_store.upcomingGames)
      ..sort((a, b) => a.kickoffTime.compareTo(b.kickoffTime));
    return games;
  }

  @override
  Future<List<Game>> fetchFinishedGames() async {
    final games = List.of(_store.finishedGames)
      ..sort((a, b) => a.kickoffTime.compareTo(b.kickoffTime));
    return games;
  }

  @override
  Future<void> saveGame(Game game) async => _store.saveGame(game);

  @override
  Future<void> recordResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
    required DateTime finishedAt,
  }) async =>
      _store.setGameResult(
        gameId: gameId,
        homeScore: homeScore,
        awayScore: awayScore,
        finishedAt: finishedAt,
      );
}

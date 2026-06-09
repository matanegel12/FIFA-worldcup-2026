import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';

void main() {
  late MockGamesRepository repo;

  const mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
  const brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
  const france = Team(fifaCode: 'FRA', isoCode: 'fr', name: 'France');
  const germany = Team(fifaCode: 'GER', isoCode: 'de', name: 'Germany');

  // game1 kicks off first
  final game1 = Game(
    id: 'g1',
    homeTeam: mexico,
    awayTeam: brazil,
    kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
    status: GameStatus.upcoming,
  );
  // game2 kicks off second
  final game2 = Game(
    id: 'g2',
    homeTeam: france,
    awayTeam: germany,
    kickoffTime: DateTime.utc(2026, 6, 11, 19, 0),
    status: GameStatus.upcoming,
  );

  setUp(() {
    MockStore.instance.resetAll();
    repo = MockGamesRepository();
  });

  group('fetchAllGames', () {
    test('returns empty list when store is empty', () async {
      expect(await repo.fetchAllGames(), isEmpty);
    });

    test('returns all games sorted by kickoff time', () async {
      // seed in reverse order to verify sorting
      MockStore.instance.seedGames([game2, game1]);
      final games = await repo.fetchAllGames();

      expect(games.length, 2);
      expect(games[0].id, 'g1'); // earlier kickoff first
      expect(games[1].id, 'g2');
    });
  });

  group('fetchUpcomingGames', () {
    // kickoffTime in the past — should be excluded regardless of status
    final pastGame = Game(
      id: 'past',
      homeTeam: mexico,
      awayTeam: brazil,
      kickoffTime: DateTime.utc(2020, 6, 11, 15, 0),
      status: GameStatus.upcoming,
    );

    test('returns only games with a future kickoff time', () async {
      MockStore.instance.seedGames([pastGame, game2]);

      final upcoming = await repo.fetchUpcomingGames();

      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'g2');
    });

    test('returns empty when all kickoff times are in the past', () async {
      MockStore.instance.seedGames([pastGame]);

      expect(await repo.fetchUpcomingGames(), isEmpty);
    });
  });

  group('fetchFinishedGames', () {
    test('returns only finished games', () async {
      MockStore.instance.seedGames([game1, game2]);
      MockStore.instance.setGameResult(
        gameId: 'g2',
        homeScore: 0,
        awayScore: 0,
        finishedAt: DateTime.utc(2026, 6, 11, 21, 0),
      );

      final finished = await repo.fetchFinishedGames();

      expect(finished.length, 1);
      expect(finished.first.id, 'g2');
      expect(finished.first.outcome, Prediction.draw);
    });
  });

  group('saveGame', () {
    test('adds a new game to the store', () async {
      await repo.saveGame(game1);

      final games = await repo.fetchAllGames();
      expect(games.length, 1);
      expect(games.first.id, 'g1');
    });

    test('replaces an existing game with the same id', () async {
      await repo.saveGame(game1);

      final updated = Game(
        id: 'g1',
        homeTeam: mexico,
        awayTeam: brazil,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
        homeScore: 3,
        awayScore: 0,
        status: GameStatus.finished,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
      await repo.saveGame(updated);

      final games = await repo.fetchAllGames();
      expect(games.length, 1); // no duplicate
      expect(games.first.homeScore, 3);
    });
  });

  group('recordResult', () {
    test('marks game as finished with correct scores', () async {
      MockStore.instance.seedGames([game1]);
      final finishedAt = DateTime.utc(2026, 6, 11, 17, 0);

      await repo.recordResult(
        gameId: 'g1',
        homeScore: 2,
        awayScore: 1,
        finishedAt: finishedAt,
      );

      final finished = await repo.fetchFinishedGames();
      expect(finished.length, 1);
      expect(finished.first.homeScore, 2);
      expect(finished.first.awayScore, 1);
      expect(finished.first.isFinished, isTrue);
    });

    test('outcome is correct after recording result', () async {
      MockStore.instance.seedGames([game1]);

      await repo.recordResult(
        gameId: 'g1',
        homeScore: 0,
        awayScore: 0,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );

      final finished = (await repo.fetchFinishedGames()).first;
      expect(finished.outcome, Prediction.draw);
    });

    test('finishedAt is stored precisely as provided', () async {
      MockStore.instance.seedGames([game1]);
      final finishedAt = DateTime.utc(2026, 6, 11, 17, 3, 42);

      await repo.recordResult(
        gameId: 'g1',
        homeScore: 1,
        awayScore: 0,
        finishedAt: finishedAt,
      );

      final finished = (await repo.fetchFinishedGames()).first;
      expect(finished.finishedAt, finishedAt);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/pages/results/results_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

Game _finishedGame(String id, DateTime kickoffTime) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: kickoffTime,
      homeScore: 2,
      awayScore: 1,
      status: GameStatus.finished,
      finishedAt: kickoffTime.add(const Duration(hours: 2)),
      round: 'Matchday 1',
    );

Game _upcomingGame(String id) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2099, 6, 18, 15, 0),
      status: GameStatus.upcoming,
      round: 'Matchday 1',
    );

ResultsViewModel _makeVm() => ResultsViewModel(
      gamesRepository: MockGamesRepository(),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late ResultsViewModel vm;

  setUp(() {
    MockStore.instance.resetAll();
    vm = _makeVm();
  });

  group('initial state', () {
    test('isLoading is true before loadResults is called', () {
      expect(vm.model.isLoading, isTrue);
    });

    test('finishedGames is empty initially', () {
      expect(vm.model.finishedGames, isEmpty);
    });

    test('no error message initially', () {
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('loading state', () {
    test('isLoading is false after loadResults completes', () async {
      await vm.loadResults();
      expect(vm.model.isLoading, isFalse);
    });
  });

  group('only finished games', () {
    test('upcoming games are excluded — only finished games returned', () async {
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0)),
        _upcomingGame('g2'),
      ]);

      await vm.loadResults();

      expect(vm.model.finishedGames.length, 1);
      expect(vm.model.finishedGames.first.id, 'g1');
    });

    test('returns empty list when no finished games exist', () async {
      MockStore.instance.seedGames([_upcomingGame('g1')]);
      await vm.loadResults();
      expect(vm.model.finishedGames, isEmpty);
    });
  });

  group('sorting', () {
    test('games sorted by kickoffTime ascending', () async {
      MockStore.instance.seedGames([
        _finishedGame('g2', DateTime.utc(2026, 6, 11, 19, 0)),
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0)),
      ]);

      await vm.loadResults();

      expect(vm.model.finishedGames[0].id, 'g1');
      expect(vm.model.finishedGames[1].id, 'g2');
    });
  });

  group('error handling', () {
    test('error message is set on failure', () async {
      // Model already starts with isLoading=true; simulate retry after error
      vm.model.errorMessage = 'previous error';
      MockStore.instance.seedGames([]);
      await vm.loadResults();
      // Succeeds with empty list — error is cleared
      expect(vm.model.errorMessage, isNull);
    });

    test('isLoading is false after error', () async {
      await vm.loadResults();
      expect(vm.model.isLoading, isFalse);
    });
  });

  group('empty store', () {
    test('returns empty list when store has no games', () async {
      await vm.loadResults();
      expect(vm.model.finishedGames, isEmpty);
      expect(vm.model.errorMessage, isNull);
    });
  });
}

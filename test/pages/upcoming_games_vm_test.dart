import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/pages/upcoming_games/upcoming_games_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const String _userId = 'test-uid-123';

/// Kickoff far in the future — always passes the kickoff > now filter.
Game _futureGame(String id, String round, {int hour = 15}) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2099, 6, 18, hour, 0),
      status: GameStatus.upcoming,
      round: round,
    );

/// Kickoff in the past — filtered out by the repository (fetchUpcomingGames).
Game _pastGame(String id) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2020, 6, 11, 15, 0),
      status: GameStatus.upcoming,
      round: 'Matchday 1',
    );

UpcomingGamesViewModel _makeVm() => UpcomingGamesViewModel(
      gamesRepository: MockGamesRepository(),
      guessesRepository: MockGuessesRepository(),
      authRepository: MockAuthRepository(),
      userId: _userId,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late UpcomingGamesViewModel vm;

  setUp(() {
    MockStore.instance.resetAll();
    vm = _makeVm();
  });

  group('initial state', () {
    test('isLoading is true before loadGames is called', () {
      expect(vm.model.isLoading, isTrue);
    });

    test('groupedGames is empty initially', () {
      expect(vm.model.groupedGames, isEmpty);
    });

    test('guesses is empty initially', () {
      expect(vm.model.guesses, isEmpty);
    });

    test('no error message initially', () {
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('loadGames — success', () {
    setUp(() {
      MockStore.instance.seedGames([
        _futureGame('g1', 'Matchday 1'),
        _futureGame('g2', 'Matchday 1'),
      ]);
    });

    test('isLoading is false after load completes', () async {
      await vm.loadGames();
      expect(vm.model.isLoading, isFalse);
    });

    test('groupedGames is populated after load', () async {
      await vm.loadGames();
      expect(vm.model.groupedGames.length, 1);
      expect(vm.model.groupedGames.first.games.length, 2);
    });

    test('no error message after successful load', () async {
      await vm.loadGames();
      expect(vm.model.errorMessage, isNull);
    });

    test('date has no time component — date only', () async {
      await vm.loadGames();
      final DateTime date = vm.model.groupedGames.first.date;
      expect(date.hour, 0);
      expect(date.minute, 0);
      expect(date.isUtc, isTrue);
    });
  });

  group('loadGames — pre-loads existing guesses', () {
    test('model.guesses is populated from stored guesses', () async {
      MockStore.instance.seedGames([_futureGame('g1', 'Matchday 1')]);
      MockStore.instance.saveGuess(const Guess(
        userId: _userId,
        gameId: 'g1',
        prediction: Prediction.teamAWins,
      ));

      await vm.loadGames();

      expect(vm.model.guesses['g1'], isNotNull);
      expect(vm.model.guesses['g1']!.prediction, Prediction.teamAWins);
    });

    test('guessForGame returns null when no guess exists', () async {
      MockStore.instance.seedGames([_futureGame('g1', 'Matchday 1')]);
      await vm.loadGames();

      expect(vm.model.guessForGame('g1'), isNull);
    });
  });

  group('loadGames — kickoff filter', () {
    test('past games are excluded from groupedGames', () async {
      MockStore.instance.seedGames([
        _pastGame('old'),
        _futureGame('g1', 'Matchday 1'),
      ]);

      await vm.loadGames();

      expect(vm.model.groupedGames.first.games.length, 1);
      expect(vm.model.groupedGames.first.games.first.id, 'g1');
    });

    test('groupedGames is empty when all games are in the past', () async {
      MockStore.instance.seedGames([_pastGame('old1'), _pastGame('old2')]);
      await vm.loadGames();
      expect(vm.model.groupedGames, isEmpty);
    });
  });

  group('loadGames — groups sorted and isUnlocked by position', () {
    test('groups are ordered with lowest round number first', () async {
      MockStore.instance.seedGames([
        _futureGame('g3', 'Matchday 14'),
        _futureGame('g1', 'Matchday 1'),
        _futureGame('g2', 'Matchday 8'),
      ]);

      await vm.loadGames();

      expect(vm.model.groupedGames[0].round, 'Matchday 1');
      expect(vm.model.groupedGames[1].round, 'Matchday 8');
      expect(vm.model.groupedGames[2].round, 'Matchday 14');
    });

  });

  group('loadGames — knockout flag', () {
    test('knockout groups (kickoff at/after cutoff) are flagged as knockout',
        () async {
      MockStore.instance.seedGames([_futureGame('k1', 'Round of 32')]);
      await vm.loadGames();
      expect(vm.model.groupedGames.first.isKnockout, isTrue);
    });
  });

  group('loadGames — retry', () {
    test('calling loadGames clears a previous error', () async {
      vm.model.errorMessage = 'previous error';
      MockStore.instance.seedGames([_futureGame('g1', 'Matchday 1')]);
      await vm.loadGames();
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('onPredictionChanged', () {
    setUp(() async {
      MockStore.instance.seedGames([_futureGame('g1', 'Matchday 1')]);
      await vm.loadGames();
    });

    test('saves guess to repository', () async {
      await vm.onPredictionChanged('g1', Prediction.teamAWins);

      final Guess? saved = MockStore.instance.getGuess(_userId, 'g1');
      expect(saved, isNotNull);
      expect(saved!.prediction, Prediction.teamAWins);
    });

    test('updates model.guesses so page can rebuild', () async {
      await vm.onPredictionChanged('g1', Prediction.draw);

      expect(vm.model.guesses['g1']?.prediction, Prediction.draw);
    });

    test('changing prediction updates the stored guess', () async {
      await vm.onPredictionChanged('g1', Prediction.teamAWins);
      await vm.onPredictionChanged('g1', Prediction.teamBWins);

      expect(vm.model.guesses['g1']?.prediction, Prediction.teamBWins);
    });

    test('guessForGame returns the saved prediction', () async {
      await vm.onPredictionChanged('g1', Prediction.draw);

      final Guess? guess = vm.model.guessForGame('g1');
      expect(guess?.prediction, Prediction.draw);
    });

    test('guess has correct userId', () async {
      await vm.onPredictionChanged('g1', Prediction.teamAWins);

      expect(vm.model.guesses['g1']?.userId, _userId);
    });
  });
}

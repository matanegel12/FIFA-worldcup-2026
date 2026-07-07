import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/prediction_summary.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/pages/predictions/predictions_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const String _userId = 'test-uid-123';

Game _upcomingGame(String id) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2099, 6, 18, 15, 0),
      status: GameStatus.upcoming,
      round: 'Matchday 1',
    );

Game _finishedGame(String id, int homeScore, int awayScore) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
      homeScore: homeScore,
      awayScore: awayScore,
      status: GameStatus.finished,
      finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      round: 'Matchday 1',
    );

Guess _guess(String gameId, Prediction prediction) => Guess(
      userId: _userId,
      gameId: gameId,
      prediction: prediction,
    );

PredictionsViewModel _makeVm() => PredictionsViewModel(
      gamesRepository: MockGamesRepository(),
      guessesRepository: MockGuessesRepository(),
      userId: _userId,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late PredictionsViewModel vm;

  setUp(() {
    MockStore.instance.resetAll();
    vm = _makeVm();
  });

  group('initial state', () {
    test('isLoading is true before loadPredictions is called', () {
      expect(vm.model.isLoading, isTrue);
    });

    test('predictions is empty initially', () {
      expect(vm.model.predictions, isEmpty);
    });

    test('no error message initially', () {
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('loading state', () {
    test('isLoading is false after loadPredictions completes', () async {
      await vm.loadPredictions();
      expect(vm.model.isLoading, isFalse);
    });
  });

  group('shows all games — not just guessed ones', () {
    test('game with no guess appears as notGuessed', () async {
      MockStore.instance.seedGames([_upcomingGame('g1')]);

      await vm.loadPredictions();

      expect(vm.model.predictions.length, 1);
      expect(vm.model.predictions.first.result, PredictionResult.notGuessed);
      expect(vm.model.predictions.first.guess, isNull);
    });

    test('returns all games even when user has no guesses', () async {
      MockStore.instance.seedGames([
        _upcomingGame('g1'),
        _upcomingGame('g2'),
      ]);

      await vm.loadPredictions();

      expect(vm.model.predictions.length, 2);
      expect(
        vm.model.predictions.every((PredictionSummary s) =>
            s.result == PredictionResult.notGuessed),
        isTrue,
      );
    });

    test('games with and without guesses both appear', () async {
      MockStore.instance.seedGames([
        _upcomingGame('g1'),
        _upcomingGame('g2'),
      ]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamAWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.length, 2);

      final PredictionSummary guessedGame = vm.model.predictions
          .firstWhere((PredictionSummary s) => s.game.id == 'g1');
      final PredictionSummary unguessedGame = vm.model.predictions
          .firstWhere((PredictionSummary s) => s.game.id == 'g2');

      expect(guessedGame.guess, isNotNull);
      expect(unguessedGame.guess, isNull);
      expect(unguessedGame.result, PredictionResult.notGuessed);
    });
  });

  group('PredictionResult.notGuessed', () {
    test('upcoming game + no guess → notGuessed', () async {
      MockStore.instance.seedGames([_upcomingGame('g1')]);
      await vm.loadPredictions();
      expect(vm.model.predictions.first.result, PredictionResult.notGuessed);
    });

    test('finished game + no guess → notGuessed', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 2, 1)]);
      await vm.loadPredictions();
      expect(vm.model.predictions.first.result, PredictionResult.notGuessed);
    });
  });

  group('PredictionResult.pending', () {
    test('game not finished + has guess → pending', () async {
      MockStore.instance.seedGames([_upcomingGame('g1')]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamAWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.pending);
    });
  });

  group('PredictionResult.correct', () {
    test('home team wins + guessed teamAWins → correct', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 2, 1)]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamAWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.correct);
    });

    test('away team wins + guessed teamBWins → correct', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 0, 3)]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamBWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.correct);
    });

    test('draw + guessed draw → correct', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 1, 1)]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.draw));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.correct);
    });
  });

  group('PredictionResult.incorrect', () {
    test('home team wins + guessed teamBWins → incorrect', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 2, 1)]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamBWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.incorrect);
    });

    test('draw + guessed teamAWins → incorrect', () async {
      MockStore.instance.seedGames([_finishedGame('g1', 0, 0)]);
      MockStore.instance.saveGuess(_guess('g1', Prediction.teamAWins));

      await vm.loadPredictions();

      expect(vm.model.predictions.first.result, PredictionResult.incorrect);
    });
  });

  group('sorting', () {
    test('predictions sorted by kickoffTime descending (latest first)', () async {
      MockStore.instance.seedGames([
        Game(
          id: 'g1',
          homeTeam: _brazil,
          awayTeam: _mexico,
          kickoffTime: DateTime.utc(2099, 6, 18, 15, 0),
          status: GameStatus.upcoming,
          round: 'Matchday 1',
        ),
        Game(
          id: 'g2',
          homeTeam: _mexico,
          awayTeam: _brazil,
          kickoffTime: DateTime.utc(2099, 6, 18, 19, 0),
          status: GameStatus.upcoming,
          round: 'Matchday 1',
        ),
      ]);

      await vm.loadPredictions();

      expect(vm.model.predictions[0].game.id, 'g2');
      expect(vm.model.predictions[1].game.id, 'g1');
    });
  });

  group('empty store', () {
    test('returns empty predictions when no games exist', () async {
      await vm.loadPredictions();
      expect(vm.model.predictions, isEmpty);
    });
  });

  group('retry', () {
    test('calling loadPredictions again clears a previous error', () async {
      vm.model.errorMessage = 'previous error';
      await vm.loadPredictions();
      expect(vm.model.errorMessage, isNull);
    });
  });
}

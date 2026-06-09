import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/models/user.dart';
import 'package:fifa_worldcup_2026_predictions/pages/upcoming_games/upcoming_games_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
const String _userId = 'test-uid-123';

Game _finishedGame(String id, DateTime kickoffTime, DateTime finishedAt) => Game(
      id: id,
      homeTeam: _mexico,
      awayTeam: _brazil,
      kickoffTime: kickoffTime,
      homeScore: 2,
      awayScore: 1,
      status: GameStatus.finished,
      finishedAt: finishedAt,
      round: 'Matchday 1',
    );

User _userWithLastVisit(DateTime? lastVisitedAt) => User(
      id: _userId,
      email: 'test@test.com',
      displayName: 'Test',
      totalPoints: 0,
      lastVisitedAt: lastVisitedAt,
    );

UpcomingGamesViewModel _makeVm() => UpcomingGamesViewModel(
      gamesRepository: MockGamesRepository(),
      guessesRepository: MockGuessesRepository(),
      userId: _userId,
      authRepository: MockAuthRepository(),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() => MockStore.instance.resetAll());

  group('_checkUnseenResults — no popup when lastVisitedAt is null', () {
    test('first-time user with null lastVisitedAt sees no popup', () async {
      MockStore.instance.seedUsers([_userWithLastVisit(null)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)),
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();

      expect(vm.model.showResultsPopup, isFalse);
      expect(vm.model.unseenGames, isEmpty);
    });
  });

  group('_checkUnseenResults — popup shown for unseen results', () {
    test('games finished after lastVisitedAt trigger popup', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 1, 0, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)), // finished AFTER lastVisit
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();

      expect(vm.model.showResultsPopup, isTrue);
      expect(vm.model.unseenGames.length, 1);
      expect(vm.model.unseenGames.first.id, 'g1');
    });

    test('only games finished after lastVisitedAt are unseen', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 11, 18, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('old', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)), // finished BEFORE lastVisit
        _finishedGame('new', DateTime.utc(2026, 6, 12, 15, 0),
            DateTime.utc(2026, 6, 12, 17, 0)), // finished AFTER lastVisit
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();

      expect(vm.model.showResultsPopup, isTrue);
      expect(vm.model.unseenGames.length, 1);
      expect(vm.model.unseenGames.first.id, 'new');
    });
  });

  group('_checkUnseenResults — no popup when all results already seen', () {
    test('lastVisitedAt after all finished games → no popup', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 20, 0, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)), // finished BEFORE lastVisit
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();

      expect(vm.model.showResultsPopup, isFalse);
      expect(vm.model.unseenGames, isEmpty);
    });
  });

  group('_hasShownPopup — only fires once per session', () {
    test('second loadGames call does not re-trigger popup', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 1, 0, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)),
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames(); // first call — popup shown

      expect(vm.model.showResultsPopup, isTrue);

      // Simulate dismissal then reload
      await vm.onPopupDismissed();
      expect(vm.model.showResultsPopup, isFalse);

      await vm.loadGames(); // second call — should NOT re-trigger
      expect(vm.model.showResultsPopup, isFalse);
    });
  });

  group('onPopupDismissed', () {
    test('sets showResultsPopup to false', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 1, 0, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)),
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();
      expect(vm.model.showResultsPopup, isTrue);

      await vm.onPopupDismissed();
      expect(vm.model.showResultsPopup, isFalse);
    });

    test('updates lastVisitedAt in the store', () async {
      final DateTime lastVisit = DateTime.utc(2026, 6, 1, 0, 0);
      MockStore.instance.seedUsers([_userWithLastVisit(lastVisit)]);
      MockStore.instance.currentUserId = _userId;
      MockStore.instance.seedGames([
        _finishedGame('g1', DateTime.utc(2026, 6, 11, 15, 0),
            DateTime.utc(2026, 6, 11, 17, 0)),
      ]);

      final UpcomingGamesViewModel vm = _makeVm();
      await vm.loadGames();
      await vm.onPopupDismissed();

      final User? updated = MockStore.instance.getUser(_userId);
      expect(updated?.lastVisitedAt, isNotNull);
      // lastVisitedAt should be updated to roughly now (after the original lastVisit)
      expect(updated!.lastVisitedAt!.isAfter(lastVisit), isTrue);
    });
  });
}

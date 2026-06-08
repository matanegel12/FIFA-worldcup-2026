import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/pages/main_shell/main_shell_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

MainShellViewModel _makeVm() => MainShellViewModel(
      gamesRepository: MockGamesRepository(),
      guessesRepository: MockGuessesRepository(),
      leaderboardRepository: MockLeaderboardRepository(),
      userId: 'test-uid-123',
    );

void main() {
  setUp(() => MockStore.instance.resetAll());

  group('initial state', () {
    test('currentIndex starts at 0 (upcoming games tab)', () {
      expect(_makeVm().model.currentIndex, 0);
    });

    test('isLoading starts false', () {
      expect(_makeVm().model.isLoading, isFalse);
    });
  });

  group('onTabChanged — valid indices', () {
    test('onTabChanged(0) sets currentIndex to 0', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(0);
      expect(vm.model.currentIndex, 0);
    });

    test('onTabChanged(1) sets currentIndex to 1', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(1);
      expect(vm.model.currentIndex, 1);
    });

    test('onTabChanged(2) sets currentIndex to 2', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(2);
      expect(vm.model.currentIndex, 2);
    });

    test('onTabChanged(3) sets currentIndex to 3', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(3);
      expect(vm.model.currentIndex, 3);
    });
  });

  group('onTabChanged — out of range is ignored', () {
    test('onTabChanged(-1) does not change currentIndex', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(-1);
      expect(vm.model.currentIndex, 0); // unchanged from initial
    });

    test('onTabChanged(4) does not change currentIndex', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(4);
      expect(vm.model.currentIndex, 0); // unchanged from initial
    });

    test('out-of-range call does not reset a previously set index', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(2);
      vm.onTabChanged(99);
      expect(vm.model.currentIndex, 2); // still 2, not reset
    });
  });

  group('repositories and userId exposed', () {
    test('userId is accessible', () {
      expect(_makeVm().userId, 'test-uid-123');
    });

    test('gamesRepository is accessible', () {
      expect(_makeVm().gamesRepository, isNotNull);
    });

    test('guessesRepository is accessible', () {
      expect(_makeVm().guessesRepository, isNotNull);
    });

    test('leaderboardRepository is accessible', () {
      expect(_makeVm().leaderboardRepository, isNotNull);
    });
  });
}

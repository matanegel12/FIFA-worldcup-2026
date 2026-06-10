import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/pages/main_shell/main_shell_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/mock_games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/mock_guesses_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

MainShellViewModel _makeVm() => MainShellViewModel(
      gamesRepository: MockGamesRepository(),
      guessesRepository: MockGuessesRepository(),
      leaderboardRepository: MockLeaderboardRepository(),
      authRepository: MockAuthRepository(),
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

    test('userId starts empty', () {
      expect(_makeVm().model.userId, '');
    });

    test('userEmail starts empty', () {
      expect(_makeVm().model.userEmail, '');
    });
  });

  group('onViewLoaded — sets userId and userEmail from route arguments', () {
    test('sets model.userId and model.userEmail from a Map', () {
      final MainShellViewModel vm = _makeVm();
      vm.onViewLoaded({'userId': 'uid-abc', 'email': 'user@example.com'});
      expect(vm.model.userId, 'uid-abc');
      expect(vm.model.userEmail, 'user@example.com');
    });

    test('leaves model values empty when data is null', () {
      final MainShellViewModel vm = _makeVm();
      vm.onViewLoaded(null);
      expect(vm.model.userId, '');
      expect(vm.model.userEmail, '');
    });

    test('leaves model values empty when data is not a Map', () {
      final MainShellViewModel vm = _makeVm();
      vm.onViewLoaded('just-a-string');
      expect(vm.model.userId, '');
      expect(vm.model.userEmail, '');
    });

    test('handles missing keys gracefully', () {
      final MainShellViewModel vm = _makeVm();
      vm.onViewLoaded(<String, String>{});
      expect(vm.model.userId, '');
      expect(vm.model.userEmail, '');
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
      expect(vm.model.currentIndex, 0);
    });

    test('onTabChanged(4) does not change currentIndex', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(4);
      expect(vm.model.currentIndex, 0);
    });

    test('out-of-range call does not reset a previously set index', () {
      final MainShellViewModel vm = _makeVm();
      vm.onTabChanged(2);
      vm.onTabChanged(99);
      expect(vm.model.currentIndex, 2);
    });
  });

  group('repositories exposed', () {
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

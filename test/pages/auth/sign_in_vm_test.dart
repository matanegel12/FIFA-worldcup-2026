import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_in/sign_in_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';

void main() {
  late SignInViewModel vm;
  late MockAuthRepository repo;

  setUp(() async {
    MockStore.instance.resetAll();
    repo = MockAuthRepository();

    // Pre-seed a user to sign in with
    await repo.signUp(
      email: 'player@test.com',
      password: 'password',
      displayName: 'Player',
    );
    await repo.signOut();

    vm = SignInViewModel(authRepository: repo);
  });

  group('SignInViewModel — initial state', () {
    test('not loading initially', () {
      expect(vm.model.isLoading, isFalse);
    });

    test('no error message initially', () {
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('SignInViewModel — signIn success', () {
    test('isLoading becomes false after successful sign in', () async {
      await vm.signIn('player@test.com', 'password');
      expect(vm.model.isLoading, isFalse);
    });

    test('no error message after successful sign in', () async {
      await vm.signIn('player@test.com', 'password');
      expect(vm.model.errorMessage, isNull);
    });

    test('user is set as current after sign in', () async {
      await vm.signIn('player@test.com', 'password');
      expect(MockStore.instance.currentUserId, isNotNull);
    });
  });

  group('SignInViewModel — signIn failure', () {
    test('shows error message for unknown email', () async {
      await vm.signIn('unknown@test.com', 'password');
      expect(vm.model.errorMessage, isNotNull);
    });

    test('isLoading is false after failed sign in', () async {
      await vm.signIn('unknown@test.com', 'password');
      expect(vm.model.isLoading, isFalse);
    });
  });
}

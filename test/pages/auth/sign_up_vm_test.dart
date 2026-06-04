import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_up/sign_up_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';

void main() {
  late SignUpViewModel vm;
  late MockAuthRepository repo;

  setUp(() {
    MockStore.instance.resetAll();
    repo = MockAuthRepository();
    vm = SignUpViewModel(authRepository: repo);
  });

  group('SignUpViewModel — initial state', () {
    test('not loading initially', () {
      expect(vm.model.isLoading, isFalse);
    });

    test('no error message initially', () {
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('SignUpViewModel — signUp success', () {
    test('creates a new user in the store', () async {
      await vm.signUp('new@test.com', 'password123', 'Alice');
      expect(MockStore.instance.users.length, 1);
    });

    test('new user has correct displayName and email', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');
      final user = MockStore.instance.users.first;
      expect(user.displayName, 'Alice');
      expect(user.email, 'alice@test.com');
    });

    test('new user starts with 0 points', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');
      expect(MockStore.instance.users.first.totalPoints, 0);
    });

    test('isLoading is false after success', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');
      expect(vm.model.isLoading, isFalse);
    });

    test('no error message after success', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('SignUpViewModel — signUp failure', () {
    test('shows error when email already in use', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');

      final vm2 = SignUpViewModel(authRepository: repo);
      await vm2.signUp('alice@test.com', 'other', 'Alice 2');

      expect(vm2.model.errorMessage, isNotNull);
    });

    test('isLoading is false after failure', () async {
      await vm.signUp('alice@test.com', 'password123', 'Alice');

      final vm2 = SignUpViewModel(authRepository: repo);
      await vm2.signUp('alice@test.com', 'other', 'Alice 2');

      expect(vm2.model.isLoading, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/user.dart';
import 'package:fifa_worldcup_2026_predictions/services/mock/mock_store.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    MockStore.instance.resetAll();
    repo = MockAuthRepository();
  });

  group('signUp', () {
    test('creates a new user and returns it', () async {
      final user = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      expect(user.email, 'alice@test.com');
      expect(user.displayName, 'Alice');
      expect(user.totalPoints, 0);
      expect(user.lastVisitedAt, isNull);
    });

    test('new user is stored in MockStore', () async {
      await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      expect(MockStore.instance.users.length, 1);
    });

    test('signs the user in after sign-up', () async {
      final user = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      expect(MockStore.instance.currentUserId, user.id);
    });

    test('throws when email is already in use', () async {
      await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      expect(
        () => repo.signUp(
          email: 'alice@test.com',
          password: 'other',
          displayName: 'Alice 2',
        ),
        throwsException,
      );
    });
  });

  group('signIn', () {
    late User alice;

    setUp(() async {
      alice = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );
      await repo.signOut(); // sign out so we can test sign-in fresh
    });

    test('returns the correct user', () async {
      final user = await repo.signIn(
        email: 'alice@test.com',
        password: 'password',
      );

      expect(user.id, alice.id);
      expect(user.email, alice.email);
    });

    test('sets currentUserId on sign-in', () async {
      await repo.signIn(email: 'alice@test.com', password: 'password');

      expect(MockStore.instance.currentUserId, alice.id);
    });

    test('throws for unknown email', () {
      expect(
        () => repo.signIn(email: 'unknown@test.com', password: 'x'),
        throwsException,
      );
    });
  });

  group('signOut', () {
    test('clears currentUserId', () async {
      await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );
      await repo.signOut();

      expect(MockStore.instance.currentUserId, isNull);
    });
  });

  group('getCurrentUser', () {
    test('returns null when no one is signed in', () async {
      expect(await repo.getCurrentUser(), isNull);
    });

    test('returns the signed-in user', () async {
      final alice = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      final current = await repo.getCurrentUser();
      expect(current?.id, alice.id);
    });

    test('returns null after sign-out', () async {
      await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );
      await repo.signOut();

      expect(await repo.getCurrentUser(), isNull);
    });
  });

  group('updateLastVisited', () {
    test('updates lastVisitedAt for the user', () async {
      final alice = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );

      final visitTime = DateTime.utc(2026, 6, 11, 20, 0);
      await repo.updateLastVisited(alice.id, visitTime);

      final updated = MockStore.instance.getUser(alice.id);
      expect(updated?.lastVisitedAt, visitTime);
    });

    test('does not affect other users', () async {
      final alice = await repo.signUp(
        email: 'alice@test.com',
        password: 'password',
        displayName: 'Alice',
      );
      await repo.signOut();

      final bob = await repo.signUp(
        email: 'bob@test.com',
        password: 'password',
        displayName: 'Bob',
      );

      await repo.updateLastVisited(
        alice.id,
        DateTime.utc(2026, 6, 11, 20, 0),
      );

      expect(MockStore.instance.getUser(bob.id)?.lastVisitedAt, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/user.dart';

void main() {
  final lastVisit = DateTime.utc(2026, 6, 11, 10, 0);
  final scoreTime = DateTime.utc(2026, 6, 11, 17, 30);

  final adminUser = User(
    id: 'uid-admin',
    email: 'matan.egel@remepy.com',
    displayName: 'Matan',
    totalPoints: 10,
    lastVisitedAt: lastVisit,
    scoreReachedAt: scoreTime,
  );

  const regularUser = User(
    id: 'uid-regular',
    email: 'player@example.com',
    displayName: 'Player',
    totalPoints: 5,
  );

  group('User.fromJson', () {
    test('creates user with all fields', () {
      final user = User.fromJson('uid-123', {
        'email': 'player@example.com',
        'displayName': 'Player',
        'totalPoints': 5,
        'lastVisitedAt': '2026-06-11T10:00:00.000Z',
        'scoreReachedAt': '2026-06-11T17:30:00.000Z',
      });

      expect(user.id, 'uid-123');
      expect(user.email, 'player@example.com');
      expect(user.totalPoints, 5);
      expect(user.lastVisitedAt, DateTime.utc(2026, 6, 11, 10, 0));
      expect(user.scoreReachedAt, DateTime.utc(2026, 6, 11, 17, 30));
    });

    test('id comes from the first argument, not the json map', () {
      final user = User.fromJson('uid-from-firestore', {
        'email': 'x@x.com',
        'displayName': 'X',
        'totalPoints': 0,
        'lastVisitedAt': null,
        'scoreReachedAt': null,
      });

      expect(user.id, 'uid-from-firestore');
    });

    test('nullable timestamps are null for a new user', () {
      final user = User.fromJson('uid-new', {
        'email': 'new@example.com',
        'displayName': 'New',
        'totalPoints': 0,
        'lastVisitedAt': null,
        'scoreReachedAt': null,
      });

      expect(user.lastVisitedAt, isNull);
      expect(user.scoreReachedAt, isNull);
    });

    test('parses timestamps as UTC', () {
      final user = User.fromJson('uid-123', {
        'email': 'x@x.com',
        'displayName': 'X',
        'totalPoints': 0,
        'lastVisitedAt': '2026-06-11T10:00:00.000Z',
        'scoreReachedAt': '2026-06-11T17:30:00.000Z',
      });

      expect(user.lastVisitedAt!.isUtc, isTrue);
      expect(user.scoreReachedAt!.isUtc, isTrue);
    });
  });

  group('User.toJson', () {
    test('does not include id in the map', () {
      expect(regularUser.toJson().containsKey('id'), isFalse);
    });

    test('serializes all fields', () {
      final json = adminUser.toJson();

      expect(json['email'], 'matan.egel@remepy.com');
      expect(json['totalPoints'], 10);
      expect(json['lastVisitedAt'], '2026-06-11T10:00:00.000Z');
      expect(json['scoreReachedAt'], '2026-06-11T17:30:00.000Z');
    });

    test('serializes null timestamps as null', () {
      final json = regularUser.toJson();

      expect(json['lastVisitedAt'], isNull);
      expect(json['scoreReachedAt'], isNull);
    });
  });

  group('round-trip', () {
    test('fromJson(toJson()) returns equal user', () {
      final restored = User.fromJson(adminUser.id, adminUser.toJson());
      expect(restored, adminUser);
    });
  });

  group('isAdmin', () {
    test('returns true for admin email', () {
      expect(adminUser.isAdmin, isTrue);
    });

    test('returns false for any other email', () {
      expect(regularUser.isAdmin, isFalse);
    });
  });

  group('copyWith', () {
    test('updates totalPoints and scoreReachedAt together', () {
      final updated = regularUser.copyWith(
        totalPoints: 10,
        scoreReachedAt: scoreTime,
      );

      expect(updated.totalPoints, 10);
      expect(updated.scoreReachedAt, scoreTime);
      expect(updated.id, regularUser.id);
      expect(updated.email, regularUser.email);
    });

    test('updates lastVisitedAt without touching other fields', () {
      final updated = regularUser.copyWith(lastVisitedAt: lastVisit);

      expect(updated.lastVisitedAt, lastVisit);
      expect(updated.totalPoints, regularUser.totalPoints);
    });
  });

  group('leaderboard tiebreaker', () {
    test('user with earlier scoreReachedAt ranks higher', () {
      final earlier = User(
        id: 'uid-1',
        email: 'a@a.com',
        displayName: 'A',
        totalPoints: 5,
        scoreReachedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
      final later = User(
        id: 'uid-2',
        email: 'b@b.com',
        displayName: 'B',
        totalPoints: 5,
        scoreReachedAt: DateTime.utc(2026, 6, 11, 19, 0),
      );

      expect(
        earlier.scoreReachedAt!.isBefore(later.scoreReachedAt!),
        isTrue,
      );
    });
  });

  group('equality', () {
    test('two users with same id are equal', () {
      final other = User.fromJson('uid-regular', regularUser.toJson());
      expect(regularUser, equals(other));
    });

    test('two users with different id are not equal', () {
      expect(adminUser, isNot(equals(regularUser)));
    });
  });
}

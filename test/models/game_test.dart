import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';

void main() {
  const brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
  const mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');

  final upcomingGame = Game(
    id: 'g1',
    homeTeam: mexico,
    awayTeam: brazil,
    kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
    status: GameStatus.upcoming,
  );

  final finishedGame = Game(
    id: 'g2',
    homeTeam: mexico,
    awayTeam: brazil,
    kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
    homeScore: 2,
    awayScore: 1,
    status: GameStatus.finished,
    finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
  );

  group('Game.fromJson', () {
    test('creates upcoming game with null scores and no finishedAt', () {
      final game = Game.fromJson({
        'id': 'g1',
        'homeTeam': mexico.toJson(),
        'awayTeam': brazil.toJson(),
        'kickoffTime': '2026-06-11T15:00:00.000Z',
        'homeScore': null,
        'awayScore': null,
        'status': 'upcoming',
        'finishedAt': null,
      });

      expect(game.id, 'g1');
      expect(game.homeScore, isNull);
      expect(game.awayScore, isNull);
      expect(game.finishedAt, isNull);
      expect(game.status, GameStatus.upcoming);
    });

    test('creates finished game with scores and finishedAt', () {
      final game = Game.fromJson({
        'id': 'g2',
        'homeTeam': mexico.toJson(),
        'awayTeam': brazil.toJson(),
        'kickoffTime': '2026-06-11T15:00:00.000Z',
        'homeScore': 2,
        'awayScore': 1,
        'status': 'finished',
        'finishedAt': '2026-06-11T17:00:00.000Z',
      });

      expect(game.homeScore, 2);
      expect(game.awayScore, 1);
      expect(game.status, GameStatus.finished);
      expect(game.finishedAt, DateTime.utc(2026, 6, 11, 17, 0));
    });

    test('parses kickoffTime and finishedAt as UTC', () {
      final game = Game.fromJson({
        'id': 'g2',
        'homeTeam': mexico.toJson(),
        'awayTeam': brazil.toJson(),
        'kickoffTime': '2026-06-11T15:00:00.000Z',
        'homeScore': 2,
        'awayScore': 1,
        'status': 'finished',
        'finishedAt': '2026-06-11T17:00:00.000Z',
      });

      expect(game.kickoffTime.isUtc, isTrue);
      expect(game.finishedAt!.isUtc, isTrue);
    });
  });

  group('Game.toJson', () {
    test('serializes all fields correctly', () {
      final json = finishedGame.toJson();

      expect(json['homeScore'], 2);
      expect(json['awayScore'], 1);
      expect(json['status'], 'finished');
      expect(json['finishedAt'], '2026-06-11T17:00:00.000Z');
    });

    test('serializes null finishedAt as null', () {
      final json = upcomingGame.toJson();
      expect(json['finishedAt'], isNull);
    });
  });

  group('round-trip', () {
    test('fromJson(toJson()) returns equal game', () {
      final restored = Game.fromJson(finishedGame.toJson());
      expect(restored, finishedGame);
    });
  });

  group('isFinished', () {
    test('returns true for finished game', () {
      expect(finishedGame.isFinished, isTrue);
    });

    test('returns false for upcoming game', () {
      expect(upcomingGame.isFinished, isFalse);
    });
  });

  group('matchDay', () {
    test('returns date-only UTC DateTime', () {
      final day = upcomingGame.matchDay;

      expect(day.isUtc, isTrue);
      expect(day.year, 2026);
      expect(day.month, 6);
      expect(day.day, 11);
      expect(day.hour, 0);
      expect(day.minute, 0);
    });

    test('two games on the same day have equal matchDay', () {
      final earlyGame = Game(
        id: 'g3',
        homeTeam: mexico,
        awayTeam: brazil,
        kickoffTime: DateTime.utc(2026, 6, 11, 12, 0),
        status: GameStatus.upcoming,
      );
      final lateGame = Game(
        id: 'g4',
        homeTeam: brazil,
        awayTeam: mexico,
        kickoffTime: DateTime.utc(2026, 6, 11, 20, 0),
        status: GameStatus.upcoming,
      );

      expect(earlyGame.matchDay, equals(lateGame.matchDay));
    });
  });

  group('outcome', () {
    test('is null for an upcoming game', () {
      expect(upcomingGame.outcome, isNull);
    });

    test('is teamAWins when homeScore > awayScore', () {
      final game = Game(
        id: 'g5',
        homeTeam: mexico,
        awayTeam: brazil,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
        homeScore: 3,
        awayScore: 1,
        status: GameStatus.finished,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
      expect(game.outcome, Prediction.teamAWins);
    });

    test('is teamBWins when awayScore > homeScore', () {
      final game = Game(
        id: 'g6',
        homeTeam: mexico,
        awayTeam: brazil,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
        homeScore: 0,
        awayScore: 2,
        status: GameStatus.finished,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
      expect(game.outcome, Prediction.teamBWins);
    });

    test('is draw when scores are equal', () {
      final game = Game(
        id: 'g7',
        homeTeam: mexico,
        awayTeam: brazil,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
        homeScore: 1,
        awayScore: 1,
        status: GameStatus.finished,
        finishedAt: DateTime.utc(2026, 6, 11, 17, 0),
      );
      expect(game.outcome, Prediction.draw);
    });

    test('correct guess matches outcome', () {
      expect(finishedGame.outcome, Prediction.teamAWins); // homeScore 2 > awayScore 1
    });
  });

  group('new results popup logic', () {
    test('finishedAt after lastVisitedAt means unseen result', () {
      final lastVisit = DateTime.utc(2026, 6, 11, 10, 0);
      expect(finishedGame.finishedAt!.isAfter(lastVisit), isTrue);
    });

    test('finishedAt before lastVisitedAt means already seen', () {
      final lastVisit = DateTime.utc(2026, 6, 11, 20, 0);
      expect(finishedGame.finishedAt!.isAfter(lastVisit), isFalse);
    });
  });

  group('equality', () {
    test('two games with same id are equal', () {
      final other = Game(
        id: 'g1',
        homeTeam: brazil,
        awayTeam: mexico,
        kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
        status: GameStatus.upcoming,
      );
      expect(upcomingGame, equals(other));
    });

    test('two games with different id are not equal', () {
      expect(upcomingGame, isNot(equals(finishedGame)));
    });
  });
}

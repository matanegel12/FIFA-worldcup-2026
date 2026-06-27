import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/services/scoring/scoring_calculator.dart';
import 'package:fifa_worldcup_2026_predictions/services/sync/hardcoded_games.dart';

void main() {
  group('kHardcodedGames', () {
    test('is not empty and every entry is a valid upcoming game', () {
      expect(kHardcodedGames, isNotEmpty);
      for (final Game g in kHardcodedGames) {
        expect(g.id, isNotEmpty);
        expect(g.status, GameStatus.upcoming);
        expect(g.homeScore, isNull);
        expect(g.awayScore, isNull);
        expect(g.kickoffTime.isUtc, isTrue);
        expect(g.homeTeam.fifaCode, isNotEmpty);
        expect(g.awayTeam.fifaCode, isNotEmpty);
      }
    });

    test('every hardcoded game falls under knockout rules', () {
      for (final Game g in kHardcodedGames) {
        expect(usesKnockoutRules(g), isTrue,
            reason: '${g.id} must kick off at/after the knockout cutoff');
      }
    });

    test('ids are unique', () {
      final ids = kHardcodedGames.map((g) => g.id).toSet();
      expect(ids.length, kHardcodedGames.length);
    });

    test('includes the Round of 32 South Africa vs Canada fixture', () {
      final Game g =
          kHardcodedGames.firstWhere((g) => g.id == '2026-06-28_RSA_CAN');
      expect(g.homeTeam.name, 'South Africa');
      expect(g.awayTeam.name, 'Canada');
      expect(g.round, 'Round of 32');
      expect(g.ground, 'Los Angeles');
      expect(g.kickoffTime, DateTime.utc(2026, 6, 28, 19, 0));
    });

    test('every fixture is labelled "Round of 32"', () {
      for (final Game g in kHardcodedGames) {
        expect(g.round, 'Round of 32');
      }
    });

    test('holds all six Round of 32 fixtures', () {
      expect(kHardcodedGames.length, 6);
    });

    test('France vs Sweden 00:00 IL is stored as the previous day in UTC', () {
      // Wed 1 Jul 00:00 IL (UTC+3) = Tue 30 Jun 21:00 UTC — crosses midnight.
      final Game g =
          kHardcodedGames.firstWhere((g) => g.id == '2026-06-30_FRA_SWE');
      expect(g.homeTeam.name, 'France');
      expect(g.awayTeam.name, 'Sweden');
      expect(g.kickoffTime, DateTime.utc(2026, 6, 30, 21, 0));
    });
  });
}

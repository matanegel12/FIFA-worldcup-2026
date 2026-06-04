import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';

void main() {
  const brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

  group('Team.fromJson', () {
    test('creates team with correct fields', () {
      final team = Team.fromJson({
        'fifaCode': 'BRA',
        'isoCode': 'br',
        'name': 'Brazil',
      });

      expect(team.fifaCode, 'BRA');
      expect(team.isoCode, 'br');
      expect(team.name, 'Brazil');
    });
  });

  group('Team.toJson', () {
    test('produces correct map', () {
      final json = brazil.toJson();

      expect(json['fifaCode'], 'BRA');
      expect(json['isoCode'], 'br');
      expect(json['name'], 'Brazil');
    });
  });

  group('round-trip', () {
    test('fromJson(toJson()) returns equal team', () {
      final restored = Team.fromJson(brazil.toJson());
      expect(restored, brazil);
    });
  });

  group('flagUrl', () {
    test('builds correct flagcdn URL from isoCode', () {
      expect(brazil.flagUrl, 'https://flagcdn.com/w80/br.png');
    });
  });

  group('equality', () {
    test('two teams with same fifaCode are equal', () {
      const other = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
      expect(brazil, equals(other));
    });

    test('two teams with different fifaCode are not equal', () {
      const argentina = Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina');
      expect(brazil, isNot(equals(argentina)));
    });

    test('fifaCode is used as hash — same code, same hash', () {
      const other = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');
      expect(brazil.hashCode, equals(other.hashCode));
    });
  });
}

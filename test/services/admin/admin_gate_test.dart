import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/services/admin/admin_gate.dart';

void main() {
  group('isAdmin', () {
    test('returns true for the admin email', () {
      expect(isAdmin('test@test.com'), isTrue);
    });

    test('returns false for any other email', () {
      expect(isAdmin('other@example.com'), isFalse);
      expect(isAdmin('matan.egel@remepy.com'), isFalse);
      expect(isAdmin('admin@test.com'), isFalse);
    });

    test('returns false for null', () {
      expect(isAdmin(null), isFalse);
    });
  });
}

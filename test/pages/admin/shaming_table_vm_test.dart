import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/models/prediction.dart';
import 'package:fifa_worldcup_2026_predictions/models/shame_entry.dart';
import 'package:fifa_worldcup_2026_predictions/pages/admin/shaming_table/shaming_table_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/shaming/mock_shaming_repository.dart';

ShameEntry _entry(String name) => ShameEntry(
      userId: 'u-$name',
      displayName: name,
      gameId: 'g1',
      gameLabel: 'Ivory Coast vs Norway',
      kickoffTime: DateTime.utc(2026, 6, 30, 17, 0),
      submittedAt: DateTime.utc(2026, 6, 30, 17, 5),
      prediction: Prediction.teamBWins,
    );

void main() {
  group('initial state', () {
    test('isLoading is true before load', () {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(),
      );
      expect(vm.model.isLoading, isTrue);
      expect(vm.model.entries, isEmpty);
      expect(vm.model.errorMessage, isNull);
    });
  });

  group('success state', () {
    test('loads entries and clears loading', () async {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(entries: [_entry('Adel')]),
      );
      await vm.loadShameEntries();

      expect(vm.model.isLoading, isFalse);
      expect(vm.model.entries, hasLength(1));
      expect(vm.model.entries.first.displayName, 'Adel');
      expect(vm.model.errorMessage, isNull);
    });

    test('empty result yields empty entries and no error', () async {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(),
      );
      await vm.loadShameEntries();

      expect(vm.model.entries, isEmpty);
      expect(vm.model.errorMessage, isNull);
      expect(vm.model.isLoading, isFalse);
    });
  });

  group('error state', () {
    test('sets errorMessage when the repository throws', () async {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(shouldThrow: true),
      );
      await vm.loadShameEntries();

      expect(vm.model.errorMessage, isNotNull);
      expect(vm.model.isLoading, isFalse);
      expect(vm.model.entries, isEmpty);
    });
  });

  group('clear table', () {
    test('clears entries and sets a success message', () async {
      final repo = MockShamingRepository(entries: [_entry('Adel'), _entry('Dana')]);
      final vm = ShamingTableViewModel(shamingRepository: repo);
      await vm.loadShameEntries();
      expect(vm.model.entries, hasLength(2));

      await vm.clearTable();

      expect(repo.clearCallCount, 1);
      expect(vm.model.entries, isEmpty);
      expect(vm.model.successMessage, 'Cleared 2 late guesses.');
      expect(vm.model.isLoading, isFalse);
    });

    test('uses singular wording for one cleared guess', () async {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(entries: [_entry('Adel')]),
      );
      await vm.clearTable();
      expect(vm.model.successMessage, 'Cleared 1 late guess.');
    });

    test('sets errorMessage when clearing throws', () async {
      final vm = ShamingTableViewModel(
        shamingRepository: MockShamingRepository(shouldThrow: true),
      );
      await vm.clearTable();
      expect(vm.model.errorMessage, isNotNull);
      expect(vm.model.isLoading, isFalse);
    });
  });
}

import '../../models/shame_entry.dart';
import 'shaming_repository.dart';

/// In-memory fake for tests and local development.
///
/// Returns whatever list it was given, or throws when [shouldThrow] is set so
/// the ViewModel's error path can be tested. [clearLateGuesses] empties the
/// list, mimicking the Firestore behaviour of removing the timestamps.
class MockShamingRepository implements ShamingRepository {
  List<ShameEntry> entries;
  final bool shouldThrow;
  int clearCallCount = 0;

  MockShamingRepository({
    List<ShameEntry> entries = const [],
    this.shouldThrow = false,
  }) : entries = List<ShameEntry>.from(entries);

  @override
  Future<List<ShameEntry>> fetchLateGuesses() async {
    if (shouldThrow) {
      throw Exception('mock shaming failure');
    }
    return entries;
  }

  @override
  Future<int> clearLateGuesses() async {
    if (shouldThrow) {
      throw Exception('mock shaming failure');
    }
    clearCallCount++;
    final int cleared = entries.length;
    entries = [];
    return cleared;
  }
}

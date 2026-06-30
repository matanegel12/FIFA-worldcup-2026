import '../../models/shame_entry.dart';

/// Read-only data source for the admin "wall of shame".
///
/// ViewModels depend only on this interface — they never know whether the
/// entries come from Firestore or an in-memory fake.
abstract class ShamingRepository {
  /// Returns every guess that was submitted after its game's kickoff, judged
  /// by a trusted server timestamp (never the device clock). Latest offenders
  /// first. Guesses without a server timestamp (made before the feature
  /// existed) cannot be judged and are omitted.
  Future<List<ShameEntry>> fetchLateGuesses();

  /// Clears the wall: removes the server timestamp from every currently-late
  /// guess so it drops off the board. The prediction itself is kept. If the
  /// user edits late again, the new save re-stamps them and they reappear.
  /// Returns how many guesses were cleared.
  Future<int> clearLateGuesses();
}

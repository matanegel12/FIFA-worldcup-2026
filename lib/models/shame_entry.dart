import 'prediction.dart';

/// One "wall of shame" record: a guess that was submitted (or changed) AFTER
/// its game's kickoff. Built by the shaming layer for the admin-only table.
///
/// [submittedAt] is a SERVER-set timestamp (Firestore `serverTimestamp()`),
/// never the device clock — so a user cannot fake an on-time guess by rolling
/// their phone's clock back. Both [submittedAt] and [kickoffTime] are UTC.
class ShameEntry {
  final String userId;
  final String displayName;
  final String gameId;
  final String gameLabel; // e.g. "Ivory Coast vs Norway"
  final DateTime kickoffTime; // UTC
  final DateTime submittedAt; // UTC, server-set (trusted)
  final Prediction prediction;

  const ShameEntry({
    required this.userId,
    required this.displayName,
    required this.gameId,
    required this.gameLabel,
    required this.kickoffTime,
    required this.submittedAt,
    required this.prediction,
  });

  /// How long after kickoff the guess was made. Always positive for a real
  /// shame entry (the detector only keeps guesses submitted after kickoff).
  Duration get lateBy => submittedAt.difference(kickoffTime);

  @override
  String toString() =>
      'ShameEntry($displayName, $gameLabel, late by ${lateBy.inMinutes}m)';
}

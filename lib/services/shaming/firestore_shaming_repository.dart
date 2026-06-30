import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/game.dart';
import '../../models/shame_entry.dart';
import 'shame_detector.dart';
import 'shaming_repository.dart';

/// Builds the wall of shame from live Firestore data.
///
/// It reads three collections — `guesses`, `games`, `users` — and hands them to
/// the pure [detectLateGuesses] function. The only "time" it trusts is the
/// `submittedAt` field that [FirestoreGuessesRepository] writes with
/// `FieldValue.serverTimestamp()`; the device clock is never consulted.
class FirestoreShamingRepository implements ShamingRepository {
  final FirebaseFirestore _firestore;

  FirestoreShamingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ShameEntry>> fetchLateGuesses() async {
    final results = await Future.wait([
      _firestore.collection('guesses').get(),
      _firestore.collection('games').get(),
      _firestore.collection('users').get(),
    ]);

    final guessesSnap = results[0];
    final gamesSnap = results[1];
    final usersSnap = results[2];

    final Map<String, Game> gamesById = {
      for (final doc in gamesSnap.docs) doc.id: Game.fromJson(doc.data()),
    };

    final Map<String, String> displayNames = {
      for (final doc in usersSnap.docs)
        doc.id: (doc.data()['displayName'] as String?) ?? 'Unknown player',
    };

    final List<TimedGuess> timed = [];
    for (final doc in guessesSnap.docs) {
      final data = doc.data();
      final Timestamp? ts = data['submittedAt'] as Timestamp?;
      // No server timestamp → guess predates this feature; we cannot prove it
      // was late, so we leave it off the wall rather than guess.
      if (ts == null) continue;

      timed.add(TimedGuess(
        userId: data['userId'] as String,
        gameId: data['gameId'] as String,
        prediction: Prediction.values.byName(data['prediction'] as String),
        submittedAt: ts.toDate().toUtc(),
      ));
    }

    return detectLateGuesses(
      guesses: timed,
      gamesById: gamesById,
      displayNamesByUserId: displayNames,
    );
  }

  @override
  Future<int> clearLateGuesses() async {
    final List<ShameEntry> late = await fetchLateGuesses();
    if (late.isEmpty) return 0;

    final WriteBatch batch = _firestore.batch();
    for (final ShameEntry e in late) {
      final String docId = '${e.userId}_${e.gameId}'; // Guess.compoundId
      batch.update(
        _firestore.collection('guesses').doc(docId),
        {'submittedAt': FieldValue.delete()},
      );
    }
    await batch.commit();
    return late.length;
  }
}

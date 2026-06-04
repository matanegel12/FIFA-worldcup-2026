import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/guess.dart';
import 'guesses_repository.dart';

class FirestoreGuessesRepository implements GuessesRepository {
  final FirebaseFirestore _firestore;

  FirestoreGuessesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('guesses');

  @override
  Future<Guess?> fetchGuess(String userId, String gameId) async {
    final doc = await _col.doc(Guess.compoundId(userId, gameId)).get();
    if (!doc.exists) return null;
    return Guess.fromJson(doc.data()!);
  }

  @override
  Future<List<Guess>> fetchGuessesForUser(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    return snap.docs.map((d) => Guess.fromJson(d.data())).toList();
  }

  @override
  Future<List<Guess>> fetchGuessesForGame(String gameId) async {
    final snap = await _col.where('gameId', isEqualTo: gameId).get();
    return snap.docs.map((d) => Guess.fromJson(d.data())).toList();
  }

  @override
  Future<void> saveGuess(Guess guess) =>
      _col.doc(Guess.compoundId(guess.userId, guess.gameId)).set(guess.toJson());
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/game.dart';
import 'games_repository.dart';

class FirestoreGamesRepository implements GamesRepository {
  final FirebaseFirestore _firestore;

  FirestoreGamesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('games');

  @override
  Future<List<Game>> fetchAllGames() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _col.orderBy('kickoffTime').get();
    return snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Game.fromJson(d.data()))
        .toList();
  }

  @override
  Future<List<Game>> fetchUpcomingGames() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _col
        .where('kickoffTime',
            isGreaterThan: DateTime.now().toUtc().toIso8601String())
        .orderBy('kickoffTime')
        .get();
    return snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Game.fromJson(d.data()))
        .toList();
  }

  @override
  Future<List<Game>> fetchFinishedGames() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _col
        .where('status', isEqualTo: GameStatus.finished.name)
        .orderBy('kickoffTime')
        .get();
    return snap.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            Game.fromJson(d.data()))
        .toList();
  }

  @override
  Future<void> saveGame(Game game) =>
      _col.doc(game.id).set(game.toJson());

  @override
  Future<void> recordResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
    required DateTime finishedAt,
  }) =>
      _col.doc(gameId).update({
        'homeScore': homeScore,
        'awayScore': awayScore,
        'status': GameStatus.finished.name,
        'finishedAt': finishedAt.toIso8601String(),
      });
}

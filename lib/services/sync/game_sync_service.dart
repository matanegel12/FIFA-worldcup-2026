import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/world_cup_api_client.dart';
import '../../models/game.dart';

class GameSyncService {
  static const Duration _syncInterval = Duration(hours: 24);
  static const String _metaCollection = 'meta';
  static const String _syncDocument = 'gamesSync';

  final WorldCupApiClient _apiClient;
  final FirebaseFirestore _firestore;

  GameSyncService({
    WorldCupApiClient? apiClient,
    FirebaseFirestore? firestore,
  })  : _apiClient = apiClient ?? WorldCupApiClient(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> syncIfNeeded() async {
    final DateTime? lastSync = await _getLastSyncTime();
    final bool needsSync = lastSync == null ||
        DateTime.now().toUtc().difference(lastSync) > _syncInterval;

    if (!needsSync) return;

    try {
      await _syncFromApi();
    } catch (e) {
      final bool hasGames = await _firestoreHasGames();
      if (hasGames) {
        return;
      }
      rethrow;
    }
  }

  Future<bool> _firestoreHasGames() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap =
          await _firestore.collection('games').limit(1).get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<DateTime?> _getLastSyncTime() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(_metaCollection)
          .doc(_syncDocument)
          .get();
      if (!doc.exists) return null;
      final Timestamp? ts = doc.data()?['lastSyncAt'] as Timestamp?;
      return ts?.toDate().toUtc();
    } catch (_) {
      return null;
    }
  }

  Future<void> _syncFromApi() async {
    final List<Game> games = await _apiClient.fetchGames();

    final WriteBatch batch = _firestore.batch();

    for (final Game game in games) {
      final DocumentReference<Map<String, dynamic>> ref =
          _firestore.collection('games').doc(game.id);

      // Only write schedule fields — never overwrite admin-entered scores.
      // status, homeScore, awayScore, finishedAt are managed by admin panel only.
      // round already carries group info e.g. "Group A", "Group B".
      batch.set(
        ref,
        {
          'id': game.id,
          'homeTeam': game.homeTeam.toJson(),
          'awayTeam': game.awayTeam.toJson(),
          'kickoffTime': game.kickoffTime.toIso8601String(),
          'round': game.round,
          'ground': game.ground,
        },
        SetOptions(merge: true),
      );
    }

    batch.set(
      _firestore.collection(_metaCollection).doc(_syncDocument),
      {'lastSyncAt': FieldValue.serverTimestamp()},
    );

    await batch.commit();
  }
}

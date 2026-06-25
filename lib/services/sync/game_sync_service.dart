import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/world_cup_api_client.dart';
import '../../models/game.dart';
import 'hardcoded_games.dart';

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
    // Manually-added games are local data, not from the API, so they must NOT
    // be gated by the 24h throttle below — otherwise a newly-added fixture only
    // appears after the next API sync window. This merge is cheap and idempotent.
    await _ensureHardcodedGames();

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

  /// Writes the hand-added knockout fixtures every startup (schedule fields only,
  /// merged — never touches admin scores). Best-effort: ignored if offline.
  Future<void> _ensureHardcodedGames() async {
    try {
      await _writeSchedule(kHardcodedGames);
    } catch (_) {
      // Offline or transient Firestore error — the next launch retries.
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
    // Hardcoded games are seeded separately in _ensureHardcodedGames (every
    // startup, not gated by the 24h throttle), so we only fetch the API here.
    final List<Game> games = await _apiClient.fetchGames();
    await _writeSchedule(games);

    await _firestore
        .collection(_metaCollection)
        .doc(_syncDocument)
        .set({'lastSyncAt': FieldValue.serverTimestamp()});
  }

  /// Writes schedule fields only — never overwrites admin-entered scores.
  /// status, homeScore, awayScore and finishedAt are managed by the admin panel.
  /// round already carries group/stage info e.g. "Group A", "Round of 32".
  Future<void> _writeSchedule(List<Game> games) async {
    final WriteBatch batch = _firestore.batch();

    for (final Game game in games) {
      final DocumentReference<Map<String, dynamic>> ref =
          _firestore.collection('games').doc(game.id);

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

    await batch.commit();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/api_football_client.dart';
import '../../models/game.dart';

class GameSyncService {
  static const Duration _syncInterval = Duration(minutes: 15);
  static const String _metaCollection = 'meta';
  static const String _syncDocument = 'gamesSync';
  // Kept in sync with ApiFootballClient._season.
  // Changing this value forces a re-sync even within the 15-min window.
  static const String _currentSeason = '2022';

  final ApiFootballClient _apiClient;
  final FirebaseFirestore _firestore;

  GameSyncService({
    ApiFootballClient? apiClient,
    FirebaseFirestore? firestore,
  })  : _apiClient = apiClient ?? ApiFootballClient(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> syncIfNeeded() async {
    final Map<String, dynamic>? meta = await _getSyncMeta();
    final Timestamp? lastSyncTs = meta?['lastSyncAt'] as Timestamp?;
    final DateTime? lastSync = lastSyncTs?.toDate().toUtc();
    final String? storedSeason = meta?['season'] as String?;

    final bool needsSync = lastSync == null ||
        DateTime.now().toUtc().difference(lastSync) > _syncInterval ||
        storedSeason != _currentSeason;

    print('[GameSyncService] syncIfNeeded called');
    print('[GameSyncService] lastSync: $lastSync');
    print('[GameSyncService] storedSeason: $storedSeason');
    print('[GameSyncService] needsSync: $needsSync');

    if (!needsSync) return;

    try {
      await _syncFromApi();
    } catch (e) {
      print('[GameSyncService] API call failed: $e');
      final bool hasGames = await _firestoreHasGames();
      if (hasGames) {
        return;
      }
      rethrow;
    }
  }

  Future<bool> _firestoreHasGames() async {
    try {
      print('[GameSyncService] checking Firestore for cached games...');
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('games')
          .limit(1)
          .get();
      print('[GameSyncService] hasGames: ${snap.docs.isNotEmpty}');
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getSyncMeta() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(_metaCollection)
          .doc(_syncDocument)
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> _syncFromApi() async {
    print('[GameSyncService] calling API-Football...');
    final List<Game> games = await _apiClient.fetchAllFixtures();
    print('[GameSyncService] games fetched from API: ${games.length}');
    print('[GameSyncService] first game: ${games.isNotEmpty ? games.first : 'none'}');

    final WriteBatch batch = _firestore.batch();

    for (final Game game in games) {
      final DocumentReference<Map<String, dynamic>> ref =
          _firestore.collection('games').doc(game.id);
      batch.set(ref, game.toJson());
    }

    batch.set(
      _firestore.collection(_metaCollection).doc(_syncDocument),
      {
        'lastSyncAt': FieldValue.serverTimestamp(),
        'season': _currentSeason,
      },
    );

    await batch.commit();
  }
}
